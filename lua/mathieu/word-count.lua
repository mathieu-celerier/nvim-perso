-- Word-count since a git ref for *current file* (TeX only) + staleness days (all filetypes).
-- Single lualine component with configurable format. Updates on BufEnter/BufWritePost/BufReadPost.

local M = {}

-- === Config ===
M.config = {
	ref = "HEAD", -- compare baseline
	show_days = true, -- append days everywhere
	days_scope = "repo", -- "repo" or "file"
	style = "icons", -- "icons" | "compact" | "minimal"
	pad = "  ", -- spacing between groups
	icons = { -- change these if you don't use Nerd Font
		net = "",
		add = "",
		del = "",
		days = "",
		plus = "+",
		minus = "−",
	},
}

-- --- utils ---
local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end
local function hex(n)
	return n and string.format("#%06x", n) or nil
end

local function tool_pipe()
	if vim.fn.executable("pandoc") == 1 then
		return "pandoc -f latex -t plain --wrap=none 2>/dev/null | wc -w"
	elseif vim.fn.executable("texcount") == 1 then
		return "texcount -brief - 2>/dev/null | tail -n1 | awk '{print $1}'"
	else
		return "wc -w"
	end
end

local function words_since(ref)
	ref = ref or M.config.ref or "HEAD"
	local file = vim.fn.expand("%:p")
	if file == "" then
		return nil, "No file"
	end
	if vim.fn.executable("git") ~= 1 then
		return nil, "git not found"
	end
	local inside = trim(vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"))
	if inside ~= "true" then
		return nil, "Not a git repo"
	end

	local esc = vim.fn.shellescape(file)
	local pipe = tool_pipe()
	local cmd_add = "git diff -U0 " .. ref .. " -- " .. esc .. " | grep -E '^\\+[^+]' | sed 's/^+//' | " .. pipe
	local cmd_del = "git diff -U0 " .. ref .. " -- " .. esc .. " | grep -E '^-([^-]|$)' | sed 's/^-//' | " .. pipe
	local added = tonumber(trim(vim.fn.system(cmd_add))) or 0
	local removed = tonumber(trim(vim.fn.system(cmd_del))) or 0
	return { added = added, removed = removed, net = added - removed }
end

local function days_since_last_commit(scope)
	if vim.fn.executable("git") ~= 1 then
		return nil
	end
	local file = vim.fn.expand("%:p")
	local cmd = (scope == "file" and file ~= "" and ("git log -1 --format=%ct -- " .. vim.fn.shellescape(file)))
		or "git log -1 --format=%ct"
	local out = trim(vim.fn.system(cmd))
	local ts = tonumber(out)
	if not ts then
		return nil
	end
	local days = math.floor((os.time() - ts) / 86400)
	if days < 0 then
		days = 0
	end
	return days
end

-- === cache and updater ===
local wc_cache = ""
local last = nil -- { added?, removed?, net?, days?, text }

local function update_cache_for_buf(bufnr)
	-- days for all filetypes
	local d = nil
	if M.config.show_days then
		d = days_since_last_commit(M.config.days_scope)
	end

	if vim.bo[bufnr].filetype == "tex" then
		local ok, r = pcall(words_since, M.config.ref)
		if ok and r then
			wc_cache = string.format("%d %d %d%s", r.added, r.removed, r.net, d and (" " .. d) or "")
			last = { added = r.added, removed = r.removed, net = r.net, days = d, text = wc_cache }
			return
		end
	end

	-- Non-TeX or diff failed -> days only (if available)
	if d ~= nil then
		wc_cache = tostring(d)
		last = { days = d, text = wc_cache }
	else
		wc_cache, last = "", nil
	end
end

function M.data()
	return last
end
function M.ref()
	return M.config.ref or "HEAD"
end

-- ===== highlights =====
local function setup_hl()
	if M._hl_done then
		return
	end
	local add = vim.api.nvim_get_hl(0, { name = "DiffAdd", link = false })
	local del = vim.api.nvim_get_hl(0, { name = "DiffDelete", link = false })
	local ok = vim.api.nvim_get_hl(0, { name = "DiagnosticOk", link = false })
	local err = vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false })
	local dim = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
	local ttl = vim.api.nvim_get_hl(0, { name = "Title", link = false })
	vim.api.nvim_set_hl(0, "WcAdd", { fg = hex(add.fg) or "#98c379" })
	vim.api.nvim_set_hl(0, "WcDel", { fg = hex(del.fg) or "#e06c75" })
	vim.api.nvim_set_hl(0, "WcDays", { fg = hex(ttl.fg) or "#61afef" })
	vim.api.nvim_set_hl(0, "WcNetPos", { fg = hex(ok.fg) or "#98c379", bold = true })
	vim.api.nvim_set_hl(0, "WcNetNeg", { fg = hex(err.fg) or "#e06c75", bold = true })
	vim.api.nvim_set_hl(0, "WcNetZero", { fg = hex(dim.fg) or "#abb2bf", bold = true })
	vim.api.nvim_set_hl(0, "WcDim", { fg = hex(dim.fg) or "#5c6370" })
	M._hl_done = true
end

-- ===== rendering helpers =====
local function render_days(days)
	local ic = M.config.icons
	return table.concat({ "%#WcDim#", ic.days, " ", "%#WcDays#", tostring(days), "d", "%*" })
end

local function render_tex(style, a, r, n, days)
	setup_hl()
	local ic = M.config.icons
	local pad = M.config.pad
	local sign = (n > 0 and ic.plus) or (n < 0 and ic.minus) or ""
	local net_group = (n > 0 and "WcNetPos") or (n < 0 and "WcNetNeg") or "WcNetZero"
	local absn = math.abs(n)

	if style == "compact" then
		-- +32 (+42/−10)  3d
		local parts = {
			"%#",
			net_group,
			"#",
			sign,
			tostring(absn),
			"%#WcDim#",
			" (",
			"%#WcAdd#",
			ic.plus,
			tostring(a),
			"%#WcDim#",
			"/",
			"%#WcDel#",
			ic.minus,
			tostring(r),
			"%#WcDim#",
			")",
		}
		if days ~= nil then
			table.insert(parts, "%#WcDim#")
			table.insert(parts, pad)
			table.insert(parts, render_days(days))
		else
			table.insert(parts, "%*")
		end
		return table.concat(parts)
	elseif style == "minimal" then
		-- +32  3d
		local parts = { "%#", net_group, "#", sign, tostring(absn) }
		if days ~= nil then
			table.insert(parts, "%#WcDim#")
			table.insert(parts, pad)
			table.insert(parts, render_days(days))
		else
			table.insert(parts, "%*")
		end
		return table.concat(parts)
	else
		-- icons (default):  +32  42/10   3d
		local parts = {
			"%#",
			net_group,
			"#",
			ic.net,
			" ",
			sign,
			tostring(absn),
			"%#WcDim#",
			pad,
			"%#WcAdd#",
			ic.add,
			tostring(a),
			"%#WcDim#",
			"/",
			"%#WcDel#",
			ic.del,
			tostring(r),
		}
		if days ~= nil then
			table.insert(parts, "%#WcDim#")
			table.insert(parts, pad)
			table.insert(parts, render_days(days))
		else
			table.insert(parts, "%*")
		end
		return table.concat(parts)
	end
end

-- ===== single-component API =====
function M.statusline()
	local d = M.data()
	if not d then
		return ""
	end
	-- TeX with word diff
	if d.added ~= nil and d.removed ~= nil and d.net ~= nil then
		return render_tex(M.config.style, d.added, d.removed, d.net, d.days)
	end
	-- days-only (any filetype)
	if M.config.show_days and d.days ~= nil then
		setup_hl()
		return render_days(d.days)
	end
	return ""
end

function M.component()
	return M.statusline()
end

-- === setup ===
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	local grp = vim.api.nvim_create_augroup("WC_TEX_UPDATE", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufReadPost" }, {
		group = grp,
		callback = function(args)
			update_cache_for_buf(args.buf)
			pcall(vim.cmd, "redrawstatus")
		end,
	})
	vim.api.nvim_create_user_command("WordsSinceRefresh", function()
		update_cache_for_buf(vim.api.nvim_get_current_buf())
		if wc_cache == "" then
			vim.notify("No data (not a git repo / no file / tools missing)", vim.log.levels.INFO)
		else
			vim.notify("Updated: " .. wc_cache)
		end
		pcall(vim.cmd, "redrawstatus")
	end, {})
end

return M

local M = {}

-- obsidian.nvim resolves `templates.folder` relative to the vault root by
-- naively concatenating it with `vim.fs.joinpath` (no special-casing of
-- absolute paths), so `templates.folder` must be a relative dirname, not an
-- absolute path. Keep the generated copy inside the vault, in a hidden dir.
local GENERATED_DIRNAME = ".nvim-templates"

-- Translates the handful of Templater expressions that
-- `Templates/Daily notes.md` actually uses into obsidian.nvim's `{{ }}`
-- substitution syntax. Anything else is left as literal `<% %>` text, which
-- is a visible failure mode rather than a silently stale reimplementation.
local function translate_templater(line)
	line = line:gsub("<%%%s*tp%.file%.title%s*%%>", "{{id}}")
	line = line:gsub('<%%%s*tp%.date%.now%("([^"]+)"%)%s*%%>', "{{time:%1}}")
	return line
end

--- Relative dirname to pass as `templates.folder` in obsidian.nvim's opts.
function M.generated_dirname()
	return GENERATED_DIRNAME
end

--- Regenerate the translated copy of `filename` (found in `vault_path`'s
--- Templates folder) if the source has changed since the last sync.
function M.sync(vault_path, filename)
	local src = vault_path .. "/Templates/" .. filename
	local generated_dir = vault_path .. "/" .. GENERATED_DIRNAME
	local dst = generated_dir .. "/" .. filename

	local src_stat = vim.uv.fs_stat(src)
	if not src_stat then
		return
	end

	local dst_stat = vim.uv.fs_stat(dst)
	if dst_stat and dst_stat.mtime.sec >= src_stat.mtime.sec then
		return
	end

	vim.fn.mkdir(generated_dir, "p")

	local lines = vim.fn.readfile(src)
	for i, line in ipairs(lines) do
		lines[i] = translate_templater(line)
	end
	vim.fn.writefile(lines, dst)
end

return M

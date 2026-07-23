local function vault_note_id(title, dir)
	local builtin = require("obsidian.builtin")

	if type(title) ~= "string" then
		return builtin.zettel_id()
	end

	local base = vim.trim(title):gsub("[/\\]", "-")
	if base == "" then
		return builtin.zettel_id()
	end

	if not dir then
		return base
	end

	local candidate = base
	local idx = 2
	local dir_path = tostring(dir)

	while vim.fn.filereadable(vim.fs.joinpath(dir_path, candidate .. ".md")) == 1 do
		candidate = string.format("%s %d", base, idx)
		idx = idx + 1
	end

	return candidate
end

local function is_empty_buffer(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	return #lines == 0 or (#lines == 1 and lines[1] == "")
end

local function maybe_populate_daily_note(note)
	local daily_note = require("mathieu.obsidian.daily_note")
	local path = note.path and tostring(note.path) or vim.api.nvim_buf_get_name(0)
	if path == "" or not daily_note.is_daily_note_path(path) then
		return
	end

	local date_str = vim.fn.fnamemodify(path, ":t:r")
	if not daily_note.is_iso_date(date_str) or not is_empty_buffer(0) then
		return
	end

	vim.api.nvim_buf_set_lines(0, 0, -1, false, daily_note.render(date_str))
end

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	opts = {
		workspaces = {
			{
				name = "work",
				path = "/home/mathieu/thesis/Obsidian-folder",
			},
		},

		notes_subdir = "0 Inbox",
		new_notes_location = "notes_subdir",
		note_id_func = vault_note_id,
		note = {
			template = nil,
		},
		link = {
			style = "wiki",
			format = "shortest",
			auto_update = true,
		},
		daily_notes = {
			folder = "3 Resources/Journal/Daily",
			date_format = "YYYY/MM-MMMM/YYYY-MM-DD",
			workdays_only = false,
		},
		attachments = {
			folder = "/5 Files",
		},
		frontmatter = {
			enabled = false,
		},
		-- Vault templates are written for Obsidian's Templater plugin, not obsidian.nvim.
		templates = {
			enabled = false,
		},
		callbacks = {
			enter_note = maybe_populate_daily_note,
		},
	},
	config = function(_, opts)
		require("obsidian").setup(opts)

		local Note = require("obsidian.note")
		local original_save = Note.save

		Note.save = function(self, save_opts)
			local ok, result = pcall(original_save, self, save_opts)
			if ok then
				return result
			end

			local err = tostring(result)
			if err:match("Vim:E94") and err:match("No matching buffer") then
				local retry_opts = vim.tbl_extend("force", save_opts or {}, { check_buffers = false })
				return original_save(self, retry_opts)
			end

			error(result)
		end
	end,
}

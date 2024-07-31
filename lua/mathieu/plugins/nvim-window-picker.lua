return {
	"s1n7ax/nvim-window-picker",
	name = "window-picker",
	event = "VeryLazy",
	version = "1.*",
	config = function()
		local ok, window_picker = pcall(require, "window-picker")
		if not ok then
			return
		end

		window_picker.setup({
			autoselect_one = true,
			include_current = false,
			filter_rules = {
				-- filter using buffer options
				bo = {
					-- if the file type is one of following, the window will be ignored
					filetype = { "neo-tree", "neo-tree-popup", "notify" },

					-- if the buffer type is one of following, the window will be ignored
					buftype = { "terminal", "quickfix" },
				},
			},
		})
	end,
}

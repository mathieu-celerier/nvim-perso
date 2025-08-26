return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count
		local wc = require("mathieu.word-count")
		wc.setup({
			ref = "HEAD",
			show_days = true, -- keep days everywhere
			days_scope = "repo", -- or "file"
			style = "icons", -- "icons" | "compact" | "minimal"
			pad = "  ",
			icons = { net = "", add = "+", del = "-", days = "", plus = "+", minus = "−" },
		})

		lualine.setup({
			options = {
				theme = "auto",
				globalstatus = true,
			},
			sections = {
				lualine_c = {
					{ "filename" },
					{
						function()
							return wc.statusline()
						end,
						colored = false,
					},
					{
						function()
							return wc.days_statusline()
						end,
						colored = false,
					},
				},
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
					},
					{ "encoding" },
					{ "fileformat" },
					{ "filetype" },
				},
			},
			inactive_sections = {
				lualine_x = {},
			},
		})
	end,
}

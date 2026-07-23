return {
	"nvim-neorg/neorg",
	pkg = false,
	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	version = "*", -- Pin Neorg to the latest stable release
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-neorg/neorg-telescope",
		"nvim-neorg/lua-utils.nvim",
		"pysan3/pathlib.nvim",
		"nvim-neotest/nvim-nio",
		"MunifTanjim/nui.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.completion"] = { config = { engine = "nvim-cmp", name = "[Norg]" } },
				["core.integrations.nvim-cmp"] = {},
				["core.integrations.telescope"] = {},
				["core.integrations.treesitter"] = {
					config = {
						configure_parsers = false,
						warn_missing_parsers = true,
					},
				},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							-- Override with $NEORG_NOTES; defaults to ~/neorg/notes.
							notes = vim.env.NEORG_NOTES or vim.fn.expand("~/neorg/notes"),
						},
						default_workspace = "notes",
					},
				},
			},
		})
	end,
}

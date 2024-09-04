return {
	"nvim-neorg/neorg",
	lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
	version = "*", -- Pin Neorg to the latest stable release
	config = function()
		require("neorg").setup({
			load = {
				["core.defaults"] = {},
				["core.completion"] = { config = { engine = "nvim-cmp", name = "[Norg]" } },
				["core.integrations.nvim-cmp"] = {},
				["core.integrations.telescope"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/neorg/notes",
						},
						default_workspace = "notes",
					},
				},
			},
		})
	end,
	run = ":Neorg sync-parsers",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
}

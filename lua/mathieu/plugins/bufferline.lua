return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "v4.*",
	opts = {
		options = {
			-- mode = "tabs",
			diagnostics = "nvim_lsp",
			offsets = { { filetype = "neo-tree", text = "File tree", text_align = "left" } },
		},
	},
}

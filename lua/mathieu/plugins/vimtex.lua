return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		-- VimTeX configuration goes here, e.g.
		-- Terminal PDF preview via tdf (kitty-graphics-protocol viewer,
		-- rendered inline by ghostty), opened in a split by
		-- ~/.local/bin/pdfview (dotfiles' bin/pdfview). No synctex
		-- forward/inverse search -- tdf doesn't support it.
		vim.g.vimtex_view_method = "general"
		vim.g.vimtex_view_general_viewer = "pdfview"
		vim.g.vimtex_view_general_options = "@pdf"
		vim.g.vimtex_latexmk_build_dir = "livepreview"
		vim.g.vimtex_compiler_latexmk = {
			options = {
				"-shell-escape",
				"-synctex=1",
				"-interaction=nonstopmode",
			},
		}
		vim.g.vimtex_quickfix_mode = 0
		vim.g.vimtex_quickfix_open_on_warning = 0
		-- vim.g.vimtex_format_enabled = 1
		-- vim.g.vimtex_format_program = "latexindent"
	end,
}

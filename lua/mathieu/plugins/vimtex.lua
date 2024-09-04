return {
	"lervag/vimtex",
	lazy = false, -- we don't want to lazy load VimTeX
	-- tag = "v2.15", -- uncomment to pin to a specific release
	init = function()
		-- VimTeX configuration goes here, e.g.
		vim.g.vimtex_view_method = "zathura"
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
	end,
}

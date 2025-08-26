return {
	"trkwyk/scrollfix.nvim",
	opts = {
		scrollfix = 20, -- percentage of the window height to lock the cursor, default to 50
		-- set scrolloff to 50 and fixeof to false is essentially scrolloff=999
		fixeof = true, -- fix cursor still and leave spaces under when near EOF, default to true
		scrollinfo = true, -- show info when scrollfix is applied, default to false
		-- for LazyVim users: if you want to disable this plugin for LazyVim dashboard, use this
		skip_filetypes = { "snacks_dashboard", "alpha" }, -- disable scrollfix for specified file types, default to {}
	},
}

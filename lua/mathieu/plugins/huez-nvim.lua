return {
	"vague2k/huez.nvim",
	-- if you want registry related features, uncomment this
	import = "huez-manager.import",
	branch = "main",
	event = "UIEnter",
	config = function()
		require("huez").setup({
			deafult = "github_light_default",
			suppress_messages = false,
		})
	end,
}

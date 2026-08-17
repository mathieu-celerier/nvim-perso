return {
	"luispflamminger/git-sync.nvim",
	opts = {
		repos = {
			{
				path = "~/Documents/obsidian-notes",
				sync_interval = 5,
				commit_template = "vault sync: {timestamp}",
			},
		},
	},
}

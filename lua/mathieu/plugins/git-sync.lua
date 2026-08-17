return {
	"luispflamminger/git-sync.nvim",
	opts = {
		repos = {
			{
				path = "~/Documents/obsidian-notes",
				sync_interval = 5,
				commit_template = "vault sync: {timestamp}",
				auto_pull = true, -- Pull before pushing (default: true)
				auto_push = true, -- Push after committing (default: true)
				add_all = true,
				pull_before_push = true,
				handle_conflicts = "pause",
			},
		},
	},
}

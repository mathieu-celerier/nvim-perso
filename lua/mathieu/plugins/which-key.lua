return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration se state:open ction below
	},
	config = function()
		local wk = require("which-key")
		local set = vim.api.nvim_set_keymap

		-- Normal mode mappings
		wk.add({
			{ "<leader>x", "<cmd>lua MiniBufremove.delete()<CR>", desc = "Close current buffer" },

			-- Files
			{ "<leader>fs", ":Telescope live_grep<CR>", desc = "Search in files using Telescope" },
			{ "<leader>ff", ":Telescope find_files<CR>", desc = "Search files using Telescope" },
			{ "<leader>ft", ":TodoTelescope<CR>", desc = "Find TODO's" },
			{ "<leader>fc", "<cmd>Telescope grep_string<CR>", desc = "Find string under cursor in cwd" },

			-- LSP
			{ "<leader>lo", "<cmd>lua vim.diagnostic.open_float()<CR>", desc = "Open LSP diagnostic window" },
			{ "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", desc = "Open loclist using split buffer" },
			{ "<leader>ll", ":Telescope loclist<CR>", desc = "Open loclist using Telescope" },
			{ "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "Go to definition" },
			{ "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "Go to declaration" },
			{ "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", desc = "Format" },
			{ "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "Toggle LSP hover" },

			-- Trouble.nvim
			{ "<leader>to", "<cmd>TroubleToggle<CR>", desc = "Toggle Trouble.nvim" },
			{ "<leader>tt", "<cmd>TodoTrouble<CR>", desc = "Open TODO's in Trouble.nvim" },

			-- Misc
			{ "<leader>g", "<cmd>LazyGit<CR>", desc = "Toggle LazyGit" },
			{
				"<leader>c",
				function()
					require("Comment.api").toggle.linewise.current()
				end,
				desc = "Comment current line",
			},
			{ "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "Code actions" },
		})

		-- Visual mode mappings
		wk.add({
			{
				"<leader>c",
				"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
				desc = "Comment selected block",
				mode = "v",
			},
			{ "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "Code actions", mode = "v" },
		})

		vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
		vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
		vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
		vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

		-- Bufferline
		set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, noremap = true })
		set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, noremap = true })
	end,
}

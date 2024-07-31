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
		-- refer to the configuration section below
	},
	config = function()
		local wk = require("which-key")
		local set = vim.api.nvim_set_keymap

		wk.register({
			["<leader>"] = {
				x = { "<cmd>lua MiniBufremove.delete()<CR>", "Close current buffer" },
				f = {
					name = "Files",
					s = { ":Telescope live_grep<CR>", "Search in files using Telescope" },
					f = { ":Telescope find_files<CR>", "Search files using Telescope" },
					t = { ":TodoTelescope<CR>", "Find TODO's" },
					c = { "<cmd>Telescope grep_string<cr>", "Find string under cursor in cwd" },
				},
				l = {
					name = "LSP",
					o = { "<cmd>lua vim.diagnostic.open_float()<CR>", "Open LSP diagnostic window" },
					q = { "<cmd>lua vim.diagnostic.setloclist()<CR>", "Open loclist using split buffer" },
					l = { ":Telescope loclist<CR>", "Open loclist using Telescope" },
					d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "Go to definition" },
					D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "Go to declaration" },
					f = { "<cmd>lua vim.lsp.buf.format()<CR>", "Format" },
					h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Toggle LSP hover" },
				},
				t = {
					name = "Trouble.nvim",
					o = { "<cmd>TroubleToggle<CR>", "Toggle Trouble.nvim" },
					t = { "<cmd>TodoTrouble<CR>", "Open TODO's in Trouble.nvim" },
				},
				c = {
					function()
						require("Comment.api").toggle.linewise.current()
					end,
					"Comment current line",
				},
			},
		})

		-- Visual mode mappings
		wk.register({
			["<leader>"] = {
				c = {
					"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
					"Comment selected block",
				},
			},
		}, { mode = "v" })

		vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
		vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
		vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
		vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

		-- Bufferline
		set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, noremap = true })
		set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, noremap = true })
	end,
}

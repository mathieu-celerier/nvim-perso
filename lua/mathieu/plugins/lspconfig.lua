return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"SmiteshP/nvim-navic",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
		{ "barreiroleo/ltex_extra.nvim", ft = { "markdown", "tex" } },
	},
	config = function()
		-- import cmp-nvim-lsp plugin
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local lspconfig_util = require("lspconfig.util")

		local keymap = vim.keymap -- for conciseness

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- Change the Diagnostic symbols in the sign column (gutter)
		-- (not in youtube nvim video)
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local navic = require("nvim-navic")

		local on_attach = function(client, bufnr)
			if client.server_capabilities.documentSymbolProvider then
				navic.attach(client, bufnr)
			end
		end

		local ltex_root_dir = function(fname)
			return lspconfig_util.root_pattern(".git", ".obsidian", "latexmkrc", "Makefile", "pyproject.toml")(fname)
				or vim.fs.dirname(fname)
		end

		vim.lsp.config("clangd", {
			capabilities = capabilities,
			cmd = {
				"clangd",
				"--background-index",
				"--function-arg-placeholders=false",
				"--completion-style=detailed",
				"--header-insertion=never",
				"--clang-tidy",
				"--offset-encoding=utf-8",
			},
		})

		vim.lsp.config("lua_ls", {
			-- configure lua server (with special settings)
			capabilities = capabilities,
			settings = {
				Lua = {
					-- make the language server recognize "vim" global
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		vim.lsp.config("ruff", {
			capabilities = capabilities,
			settings = {
				init_options = {
					settings = {},
				},
			},
		})

		vim.lsp.config("pyright", {
			capabilities = capabilities,
			settings = {
				init_options = {
					settings = {},
				},
			},
		})

		-- Optional n-gram language model for LTeX. Override the location with
		-- $LTEX_NGRAMS_DIR; the setting is only sent if the directory exists so a
		-- fresh machine without the models does not error.
		local ltex_ngrams_dir = vim.env.LTEX_NGRAMS_DIR or vim.fn.expand("~/.local/models/ngrams/")
		local ltex_additional_rules = {}
		if vim.fn.isdirectory(ltex_ngrams_dir) == 1 then
			ltex_additional_rules.languageModel = ltex_ngrams_dir
		end

		vim.lsp.config("ltex", {
			-- configure lua server (with special settings)
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
			root_dir = ltex_root_dir,
			on_attach = function(...)
				require("ltex_extra").setup({
					load_langs = { "en-US", "fr" }, -- table <string> : languages for witch dictionaries will be loaded
					init_check = true, -- boolean : whether to load dictionaries on startup
					path = ".ltex", -- store LTeX state once per project root
					log_level = "none", -- string : "none", "trace", "debug", "info", "warn", "error", "fatal"
				})
			end,
			settings = {
				ltex = {
					language = "en-US",
					configurationTarget = {
						dictionary = "workspaceFolderExternalFile",
						disabledRules = "workspaceFolderExternalFile",
						hiddenFalsePositives = "workspaceFolderExternalFile",
					},
					additionalRules = ltex_additional_rules,
				},
			},
		})

		vim.lsp.config("marksman", {
			capabilities = capabilities,
		})

		for _, server in ipairs({
			"clangd",
			"lua_ls",
			"ruff",
			"pyright",
			"ltex",
			"marksman",
		}) do
			vim.lsp.enable(server)
		end
	end,
}

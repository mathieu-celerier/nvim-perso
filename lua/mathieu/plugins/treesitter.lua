return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

    parser_config.norg = {
      install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg",
        revision = "v0.2.4",
        files = { "src/parser.c", "src/scanner.cc" },
        cxx_standard = "c++14",
        use_makefile = true,
      },
      filetype = "norg",
    }

    parser_config.norg_meta = {
      install_info = {
        url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
        revision = "v0.1.0",
        files = { "src/parser.c" },
      },
      filetype = "norg_meta",
    }

    -- configure treesitter
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      -- enable indentation
      indent = { enable = true },
      -- enable autotagging (w/ nvim-ts-autotag plugin)
      autotag = {
        enable = true,
      },
      -- ensure these language parsers are installed
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "svelte",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "vimdoc",
        "c",
        "cpp",
        "norg",
        "norg_meta",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}

# Neovim Setup

This repository is a personal Neovim configuration built around `lazy.nvim`, `mason.nvim`, `nvim-lspconfig`, `telescope.nvim`, `nvim-treesitter`, and a small set of writing-focused tools for LaTeX, Markdown, Obsidian, and Neorg.

The goal of this README is practical:

- explain what this config does
- list what must be installed before it works well
- separate required dependencies from optional ones
- call out repo-specific assumptions and current caveats

## Overview

This setup is organized like this:

- [init.lua](/home/mathieu/.config/nvim/init.lua): entrypoint
- [lua/mathieu/core/options.lua](/home/mathieu/.config/nvim/lua/mathieu/core/options.lua): basic editor options
- [lua/mathieu/core/keymaps.lua](/home/mathieu/.config/nvim/lua/mathieu/core/keymaps.lua): global keymaps
- [lua/mathieu/lazy.lua](/home/mathieu/.config/nvim/lua/mathieu/lazy.lua): `lazy.nvim` bootstrap
- [lua/mathieu/plugins](/home/mathieu/.config/nvim/lua/mathieu/plugins): one plugin spec per file
- [lua/mathieu/word-count.lua](/home/mathieu/.config/nvim/lua/mathieu/word-count.lua): custom statusline helper for TeX word diffs and git staleness

Main feature areas:

- file navigation: `nvim-tree`, `bufferline`, `telescope`
- LSP and diagnostics: `nvim-lspconfig`, `mason`, `nvim-lint`, `trouble`
- completion and snippets: `nvim-cmp`, `LuaSnip`, LaTeX snippets
- formatting: `conform.nvim`
- Git: `gitsigns`, `lazygit.nvim`, custom git-based word count
- writing: `vimtex`, `markdown-preview.nvim`, `obsidian.nvim`, `neorg`
- sessions and UI: `alpha`, `auto-session`, `which-key`, `lualine`, `huez`, `auto-dark-mode`

## Neovim Version

Use Neovim `0.11+`.

This repo currently uses `vim.lsp.config(...)` in [lua/mathieu/plugins/lspconfig.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/lspconfig.lua), which is part of the newer LSP API. The machine inspected for this README is running `NVIM v0.11.3`.

## Step-By-Step Install

### 1. Install base system packages

These are the baseline packages this config expects for normal use:

- `neovim` `>= 0.11`
- `git`
- `curl` or `wget`
- `unzip`
- `tar`
- `gzip`
- `make`
- `gcc` or `clang`
- `node` and `npm`
- `python3` and `pip`

Recommended in practice:

- `ripgrep`
- `fd`
- `xclip` on X11 Linux or `wl-clipboard` on Wayland
- a Nerd Font

Why these matter:

- `lazy.nvim` bootstraps itself by cloning from GitHub, so `git` is mandatory.
- `mason.nvim` shells out to archive and download tools such as `curl`/`wget`, `unzip`, `tar`, and `gzip`.
- `telescope-fzf-native.nvim` builds with `make` and a C compiler.
- `markdown-preview.nvim` uses a Node-based preview app.
- `LuaSnip` is configured to build `jsregexp` with `make install_jsregexp`.
- clipboard integration is enabled with `opt.clipboard:append("unnamedplus")`, so Linux users generally need `xclip` or `wl-copy`.

### 2. Clone this config

Back up any existing config first, then place this repo at:

```sh
~/.config/nvim
```

### 3. Start Neovim once

On first launch:

- `lazy.nvim` will bootstrap itself
- plugins pinned in [lazy-lock.json](/home/mathieu/.config/nvim/lazy-lock.json) will be installed
- plugin build steps will run where configured

Then run:

```vim
:Lazy sync
```

### 4. Let Mason install managed tools

This repo configures Mason in [lua/mathieu/plugins/mason.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/mason.lua).

The config asks Mason to install these LSP servers:

- `lua_ls`
- `pyright`
- `clangd`
- `astro`

It also asks Mason to install these formatter/linter tools:

- `prettier`
- `stylua`
- `isort`
- `black`
- `pylint`

Open Neovim and run:

```vim
:Mason
```

If anything above is missing, install it from Mason manually.

### 5. Install the tools this config uses but does not auto-install

This is the part most likely to be missed.

#### Required for configured features

- `eslint_d`
  Used by [lua/mathieu/plugins/linting.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/linting.lua) for JavaScript, TypeScript, React, and Svelte linting.

- `tex-fmt`
  Used by [lua/mathieu/plugins/formatting.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/formatting.lua) for `tex` and `plaintex`.

- `ltex-ls-plus` or another working LTEX server setup
  [lua/mathieu/plugins/lspconfig.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/lspconfig.lua) configures `ltex`, but Mason is not set to install it.

#### Required for repo-specific workflows

- `latexmk`
  Required by `vimtex` for LaTeX compilation.

- `zathura`
  Required by this repo specifically because [lua/mathieu/plugins/vimtex.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/vimtex.lua) sets:
  `vim.g.vimtex_view_method = "zathura"`

#### Optional but used when available

- `lazygit`
  Needed for `:LazyGit`.

- `tmux`
  Needed for `vim-tmux-navigator`.

- `ssh` and `scp`
  Needed for `remote-nvim`.

- `devpod`
  Needed only for `remote-nvim` devcontainer workflows.

- `uv`
  Needed for `uv.nvim`.

- `detex`, `texcount`, or `pandoc`
  Used by [lua/mathieu/word-count.lua](/home/mathieu/.config/nvim/lua/mathieu/word-count.lua) to count TeX words in git diffs. The fallback is plain `wc -w`, but the LaTeX-aware tools are better.

### 6. Run health checks

After installation:

```vim
:checkhealth
:checkhealth mason
:checkhealth vimtex
:checkhealth remote-nvim
```

For plugin state and build failures:

```vim
:Lazy
:Mason
```

## Dependency Matrix

### Core bootstrap

- `lazy.nvim`
  Requires `git`. Upstream also recommends a Nerd Font and `luarocks` for rockspec installs.

- `plenary.nvim`
  Lua helper library. No external binary dependency by itself.

### Search and navigation

- `telescope.nvim`
  Works without extra binaries, but this config maps `live_grep`, so `ripgrep` is effectively required for full functionality.

- `telescope-fzf-native.nvim`
  Requires `make` plus `gcc` or `clang` because this repo builds it with `make`.

- `nvim-tree`
  No mandatory external binaries.

- `bufferline`, `window-picker`, `smart-splits`, `scrollfix`, `mini.bufremove`
  No external binaries.

### LSP, completion, formatting, linting

- `nvim-lspconfig`
  Depends on actual language servers being installed.

- `mason.nvim`
  Requires download/archive utilities. It may also rely on ecosystem package managers depending on the tool being installed.

- `mason-lspconfig.nvim`
  Bridges Mason package install names and LSP server names.

- `mason-tool-installer.nvim`
  Auto-installs Mason packages listed in this repo.

- `nvim-cmp`
  No external binary by itself.

- `LuaSnip`
  This repo builds optional `jsregexp`, so `make` and a C compiler are required.

- `conform.nvim`
  Only formats through external formatters that must exist on `$PATH`.

- `nvim-lint`
  Only lints through external linters that must exist on `$PATH`.

Configured language servers and tooling in this repo:

| Area | Tool | How it is expected to be installed |
| --- | --- | --- |
| Lua LSP | `lua_ls` | Mason |
| Python LSP | `pyright` | Mason |
| C/C++ LSP | `clangd` | Mason |
| Astro LSP | `astro` | Mason |
| Python LSP | `ruff` | not auto-installed here; install manually if you want it |
| Markdown/LaTeX prose LSP | `ltex` | not auto-installed here; install manually |
| JS/TS/CSS/HTML/Markdown formatter | `prettier` | Mason |
| Lua formatter | `stylua` | Mason |
| Python formatters | `black`, `isort` | Mason |
| Python linter | `pylint` | Mason |
| JS/TS/Svelte linter | `eslint_d` | manual |
| TeX formatter | `tex-fmt` | manual or Mason |

Notes:

- `pyright`, `prettier`, and `astro-language-server` are Node ecosystem tools under Mason.
- `black`, `pylint`, and `isort` are Python ecosystem tools under Mason.
- `clangd`, `lua-language-server`, and `tex-fmt` are distributed as standalone binaries/releases in Mason.

## Writing And Notes Features

### LaTeX

LaTeX support comes from:

- `vimtex`
- `cmp-vimtex`
- `luasnip-latex-snippets`
- `conform.nvim` with `tex-fmt`
- custom git word-count in the statusline

To use the LaTeX workflow properly, install:

- a TeX distribution
- `latexmk`
- `zathura`
- `tex-fmt`

Helpful extras for the word-count statusline:

- `detex`
- `texcount`
- `pandoc`

The custom statusline helper:

- only computes added/removed words for TeX buffers
- expects the file to be inside a git repo
- also shows days since last commit

### Markdown

Markdown support comes from:

- Treesitter
- `markdown-preview.nvim`
- `obsidian.nvim`
- `ltex` configuration for prose checking

To use Markdown preview comfortably:

- install `node`
- ensure you have a browser available

If you use Obsidian image paste on Linux:

- install `xclip` for X11 or `wl-clipboard` for Wayland

If you want Obsidian quick search and switching:

- install `ripgrep`

### Obsidian

This repo is hard-coded to this vault path:

```sh
/home/mathieu/thesis/Obsidian-folder/
```

That directory exists on the inspected machine. If you use a different vault, update [lua/mathieu/plugins/obsidian-nvim.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/obsidian-nvim.lua).

Daily notes are expected under:

```sh
3 Resources/Periodic notes/Daily notes
```

inside the vault.

### Neorg

Neorg is configured with this workspace:

```sh
~/neorg/notes
```

That directory exists on the inspected machine.

Neorg also depends on Treesitter and uses `nvim-cmp` integration in this config.

## Git And Terminal Integration

- `gitsigns.nvim`
  No extra dependency beyond `git`.

- `lazygit.nvim`
  Requires the `lazygit` binary.

- custom word count module
  Requires `git`; optional `detex`/`texcount`/`pandoc`.

- `vim-tmux-navigator`
  Requires `tmux` if you want pane navigation between Neovim and tmux.

## UI And Session Plugins

- `alpha-nvim`
- `which-key.nvim`
- `lualine.nvim`
- `indent-blankline.nvim`
- `dressing.nvim`
- `auto-session`
- `nvim-surround`
- `substitute.nvim`
- `Comment.nvim`
- `nvim-autopairs`
- `todo-comments.nvim`
- `trouble.nvim`
- `vim-maximizer`

These do not need extra system packages beyond standard Neovim prerequisites.

### Theme switching

This repo uses `huez.nvim` as the colorscheme selector.

Important caveat:

- [lua/mathieu/plugins/huez-nvim.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/huez-nvim.lua) configures `huez`
- several old colorscheme plugin specs have been removed from the repo
- [lazy-lock.json](/home/mathieu/.config/nvim/lazy-lock.json) still contains stale lock entries for some themes

So theme switching is configured, but the actual set of installed theme plugins may not match the lockfile history.

### Auto dark mode

`auto-dark-mode.nvim` needs OS support for system appearance detection:

- Linux desktop implementing `org.freedesktop.appearance.color-scheme`
- macOS Mojave+
- Windows 10+

## Remote Development

`remote-nvim.nvim` is installed and configured with defaults.

For plain SSH remote editing you need:

- `ssh`
- `scp`
- `curl`
- remote host with `bash`

For devcontainer workflows you also need:

- `devpod >= 0.5`

This plugin also needs network access to download remote Neovim builds unless you use its offline mode.

## Clipboard

This config enables:

```lua
opt.clipboard:append("unnamedplus")
```

On Linux that usually means:

- `xclip` on X11
- `wl-copy` / `wl-paste` from `wl-clipboard` on Wayland

Without one of those providers, system clipboard support will be incomplete.

## Key Bindings You Will Use Immediately

Core bindings defined in this repo:

- `<leader>ee`: toggle file tree
- `<leader>ff`: find files
- `<leader>fs`: live grep
- `<leader>ft`: search TODOs
- `<leader>g`: open LazyGit
- `<leader>wr`: restore session
- `<leader>ws`: save session
- `<leader>mp`: format current buffer/range
- `<leader>l`: trigger linting
- `gd`, `gD`, `gR`, `gi`, `gt`, `K`: LSP navigation and hover
- `<Tab>` / `<S-Tab>`: cycle buffers
- `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>`: split navigation

See:

- [lua/mathieu/core/keymaps.lua](/home/mathieu/.config/nvim/lua/mathieu/core/keymaps.lua)
- [lua/mathieu/plugins/which-key.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/which-key.lua)
- [lua/mathieu/plugins/lspconfig.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/lspconfig.lua)

## Current Caveats In This Repo

These are real caveats from the checked-in config.

### LSP servers are configured, but not explicitly enabled

[lua/mathieu/plugins/lspconfig.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/lspconfig.lua) defines server configs with `vim.lsp.config(...)`, but this repo does not currently call `vim.lsp.enable(...)` anywhere.

That means:

- Mason may install the servers
- the configuration exists
- but LSP startup may still not happen automatically until explicit enable calls are added

If you want the new Neovim 0.11 flow, add something like:

```lua
vim.lsp.enable("lua_ls")
vim.lsp.enable("pyright")
vim.lsp.enable("clangd")
vim.lsp.enable("astro")
vim.lsp.enable("ruff")
vim.lsp.enable("ltex")
```

### LTEX has an extra local path assumption

The LTEX config sets:

```lua
additionalRules = {
  languageModel = "~/.local/models/ngrams/",
}
```

On the inspected machine, that directory is currently missing. If you want LTEX language-model support, create/populate that path or remove that option.

### `ruff` is configured but not installed by Mason here

The repo defines a `ruff` LSP config, but [lua/mathieu/plugins/mason.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/mason.lua) does not ensure-install `ruff`.

### `eslint_d` and `tex-fmt` are used but not auto-installed

Formatting/linting for some filetypes will silently be incomplete until you install them.

## Suggested Install Checklist

If you want the shortest path to a working setup on Linux, install at least:

- `neovim`
- `git`
- `curl`
- `unzip`
- `tar`
- `gzip`
- `make`
- `gcc`
- `node`
- `npm`
- `python3`
- `pip`
- `ripgrep`
- `fd`
- `xclip` or `wl-clipboard`
- `tmux`
- `lazygit`
- `latexmk`
- `zathura`

Then inside Neovim install or verify:

- Mason-managed: `lua_ls`, `pyright`, `clangd`, `astro`, `prettier`, `stylua`, `isort`, `black`, `pylint`
- extra manual tools: `eslint_d`, `tex-fmt`, `ruff`, `ltex-ls-plus`, `uv`

## Upstream References

These upstream docs were the important ones for the dependency audit:

- `lazy.nvim`: <https://github.com/folke/lazy.nvim>
- `mason.nvim`: <https://github.com/mason-org/mason.nvim>
- `telescope-fzf-native.nvim`: <https://github.com/nvim-telescope/telescope-fzf-native.nvim>
- `LuaSnip`: <https://github.com/L3MON4D3/LuaSnip>
- `markdown-preview.nvim`: <https://github.com/iamcco/markdown-preview.nvim>
- `vimtex`: <https://github.com/lervag/vimtex>
- `obsidian.nvim`: <https://github.com/epwalsh/obsidian.nvim>
- `remote-nvim.nvim`: <https://github.com/amitds1997/remote-nvim.nvim>
- `uv.nvim`: <https://github.com/benomahony/uv.nvim>
- `auto-dark-mode.nvim`: <https://github.com/f-person/auto-dark-mode.nvim>

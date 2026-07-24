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

Pick the block for your system. These cover the base packages plus the
recommended extras (`ripgrep`, `fd`, clipboard, `tmux`, `lazygit`) and the
manual tools this config uses but does not auto-install (`latexmk`, `zathura`).

#### Debian / Ubuntu

```sh
sudo apt update
sudo apt install -y \
  neovim git curl wget unzip tar gzip make gcc \
  nodejs npm python3 python3-pip python3-venv \
  ripgrep fd-find xclip wl-clipboard tmux lazygit \
  latexmk zathura texlive-full
```

> On Debian/Ubuntu the `fd` binary is called `fdfind`; symlink it if you want
> the `fd` name: `mkdir -p ~/.local/bin && ln -s "$(which fdfind)" ~/.local/bin/fd`.
> If the distro's `neovim` is older than 0.11, use the unstable PPA
> (`sudo add-apt-repository ppa:neovim-ppa/unstable`) or the AppImage from
> <https://github.com/neovim/neovim/releases>.

#### Arch / Manjaro

```sh
sudo pacman -S --needed \
  neovim git curl wget unzip tar gzip make gcc \
  nodejs npm python python-pip \
  ripgrep fd xclip wl-clipboard tmux lazygit \
  texlive-most zathura zathura-pdf-mupdf
```

#### Fedora

```sh
sudo dnf install -y \
  neovim git curl wget unzip tar gzip make gcc \
  nodejs npm python3 python3-pip \
  ripgrep fd-find xclip wl-clipboard tmux lazygit \
  latexmk zathura texlive-scheme-full
```

#### macOS (Homebrew)

```sh
brew install \
  neovim git curl wget gnu-tar make gcc \
  node python ripgrep fd tmux lazygit
brew install --cask mactex zathura
```

> macOS ships `unzip`, `gzip`, and `tar`, and uses the system clipboard, so
> `xclip`/`wl-clipboard` are not needed. A TeX distribution via `mactex` is
> large; `basictex` plus `latexmk` is a lighter alternative.

Also install a Nerd Font for the UI icons (any patched font works):
<https://www.nerdfonts.com/font-downloads>.

### 2. Clone this config

Back up any existing config and state, then clone this repo to `~/.config/nvim`:

```sh
# Back up an existing config (only runs if one is present)
[ -e ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
[ -e ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.bak.$(date +%s)

# Clone this config into place
git clone <this-repo-url> ~/.config/nvim
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

#### Copy-paste install for the manual tools

`eslint_d` and `tex-fmt` are easiest to install from Mason (`:MasonInstall
eslint_d tex-fmt`). The rest come from their own ecosystems:

```sh
# Node-based: eslint_d (JS/TS/Svelte linting)
npm install -g eslint_d

# Rust-based: tex-fmt (LaTeX formatter) and uv (Python env manager)
cargo install tex-fmt          # or: download a release binary from GitHub
curl -LsSf https://astral.sh/uv/install.sh | sh

# ruff (Python LSP/linter) — install via uv or pipx
uv tool install ruff           # or: pipx install ruff

# ltex-ls-plus (prose LSP) — grab a release archive and put it on $PATH
#   https://github.com/ltex-plus/ltex-ls-plus/releases

# texcount / detex usually ship with your TeX distribution; pandoc is separate:
#   Debian/Ubuntu: sudo apt install -y pandoc
#   Arch:          sudo pacman -S pandoc
#   Fedora:        sudo dnf install -y pandoc
#   macOS:         brew install pandoc
```

> `remote-nvim` needs `ssh`/`scp` (usually preinstalled) and, only for
> devcontainer workflows, `devpod >= 0.5` from
> <https://github.com/loft-sh/devpod/releases>.

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
  Requires `git`. Upstream also recommends a Nerd Font. Some plugins pull in
  Lua rock dependencies, which `lazy.nvim` installs through `luarocks` /
  `hererocks` — see [Luarocks / hererocks](#luarocks--hererocks) below if that
  step fails.

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

This repo defaults to this vault path:

```sh
~/thesis/Obsidian-folder/
```

To use a different vault, set the `OBSIDIAN_VAULT` environment variable, or edit [lua/mathieu/plugins/obsidian-nvim.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/obsidian-nvim.lua).

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

Override it with the `NEORG_NOTES` environment variable if you keep notes elsewhere.

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

## Luarocks / hererocks

Some plugins declare Lua rock dependencies (rockspecs). When `lazy.nvim` sees
one, it installs the rock into an isolated Lua env that it builds with
[`hererocks`](https://github.com/luarocks/hererocks) — a Python script that
compiles a private Lua + `luarocks` under `~/.local/share/nvim/lazy-rocks/`.
This is the step that commonly breaks on a fresh machine, so it gets its own
section here.

`hererocks` needs, on `$PATH`:

- `python3` (it is a Python script)
- `git`, `curl` or `wget` (to fetch Lua and luarocks)
- a C toolchain: `make` plus `gcc`/`clang`, and the Lua headers
- `unzip` (luarocks unpacks rock archives)

Install the build prerequisites:

```sh
# Debian / Ubuntu
sudo apt install -y build-essential libreadline-dev unzip python3 curl git

# Arch
sudo pacman -S --needed base-devel readline unzip python curl git

# Fedora
sudo dnf install -y @development-tools readline-devel unzip python3 curl git

# macOS (Xcode command line tools provide the compiler)
xcode-select --install
```

### Checking and repairing the rocks env

- `:checkhealth lazy` reports whether `luarocks` / `hererocks` are usable and
  prints the exact error when they are not.
- If the private env got into a bad state, delete it and let `lazy.nvim`
  rebuild it on the next launch:

  ```sh
  rm -rf ~/.local/share/nvim/lazy-rocks
  ```

  then reopen Neovim and run `:Lazy sync`.

### Error: "luarocks ... Lua 5.1 not installed" / "hererocks ... Lua 5.1"

Rocks are built against **Lua 5.1** (Neovim's runtime is LuaJIT, which is 5.1
compatible), so `luarocks` needs a Lua 5.1 interpreter.

**Try this first — it is usually all that is needed:**

```sh
# Debian / Ubuntu
sudo apt install -y luarocks
```

Installing the system `luarocks` package pulls in a working Lua 5.1 toolchain,
which resolved this error in practice. Then reopen Neovim and run `:Lazy sync`.
The equivalent on other distros is `sudo pacman -S luarocks` (Arch),
`sudo dnf install luarocks` (Fedora), or `brew install luarocks` (macOS).

If that alone does not fix it, this error means one of two things:

1. **`lazy.nvim` is using `hererocks` but cannot build its private Lua 5.1.**
   hererocks downloads the Lua 5.1 source and compiles it, which fails without a
   C compiler and the readline headers. Install the build prerequisites from the
   [Luarocks / hererocks](#luarocks--hererocks) section above, wipe the env
   (`rm -rf ~/.local/share/nvim/lazy-rocks`), and run `:Lazy sync` again.

2. **`lazy.nvim` picked up a system `luarocks` that has no Lua 5.1 behind it.**
   A distro `luarocks` is often wired to Lua 5.4, so it reports 5.1 as missing.
   The most reliable fix is to install a matching Lua 5.1 + luarocks pair and
   tell lazy.nvim to skip hererocks:

   ```sh
   # Debian / Ubuntu
   sudo apt install -y lua5.1 liblua5.1-0-dev luarocks

   # Arch
   sudo pacman -S --needed lua51 luarocks

   # Fedora
   sudo dnf install -y compat-lua compat-lua-devel luarocks

   # macOS
   brew install lua@5.1 luarocks
   ```

   Then point lazy.nvim at the system luarocks instead of hererocks in the
   options table of
   [lua/mathieu/lazy.lua](/home/mathieu/.config/nvim/lua/mathieu/lazy.lua):

   ```lua
   rocks = {
     hererocks = false, -- use system luarocks/lua5.1 instead of a private build
   },
   ```

If neither route is worth the trouble, just disable rocks entirely — see below.

### If you cannot get luarocks working

Rock support is optional for this config. You can either disable it globally by
adding `rocks = { enabled = false }` to the options table in
[lua/mathieu/lazy.lua](/home/mathieu/.config/nvim/lua/mathieu/lazy.lua):

```lua
require("lazy").setup({ { import = "mathieu.plugins" } }, {
  rocks = { enabled = false },
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
```

or, if a specific plugin only wants a rock in order to pull a Lua library that
is also available as a normal plugin, add `pkg = false` to that plugin's spec so
`lazy.nvim` skips its rockspec. The Neorg spec in
[lua/mathieu/plugins/neorg.lua](/home/mathieu/.config/nvim/lua/mathieu/plugins/neorg.lua)
already does this (`pkg = false`) and lists its Lua dependencies
(`lua-utils.nvim`, `pathlib.nvim`, `nui.nvim`, `nvim-nio`) as plain plugins, so
Neorg here does **not** require a working luarocks/hererocks toolchain.

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

### Machine-specific paths are overridable via environment variables

The personal paths in this config now default sensibly and can be overridden
without editing Lua:

| Variable | Default | Used by |
| --- | --- | --- |
| `OBSIDIAN_VAULT` | `~/thesis/Obsidian-folder` | `obsidian.nvim` |
| `NEORG_NOTES` | `~/neorg/notes` | Neorg workspace |
| `LTEX_NGRAMS_DIR` | `~/.local/models/ngrams/` | LTEX n-gram language model (optional) |

The LTEX `languageModel` setting is only sent to the server when the directory
exists, so a fresh machine without the models will not error.

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

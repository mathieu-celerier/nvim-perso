local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local opts = {
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		notify = false,
	},
}

-- On the Nix-managed machine, NVIM_PLUGIN_FARM points at a linkFarm of
-- pinned plugin sources (see dotfiles' nix/nvim-plugins.nix). When present,
-- lazy.nvim treats every plugin as local instead of git-cloning it.
-- `fallback = true` means a plugin missing from the farm still installs
-- normally, so this repo and the farm don't have to be updated in lockstep.
-- Absent (e.g. a plain clone on another machine), lazy.nvim behaves exactly
-- as before.
local plugin_farm = vim.env.NVIM_PLUGIN_FARM
local on_nix = plugin_farm and vim.fn.isdirectory(plugin_farm) == 1
if on_nix then
	opts.dev = {
		path = plugin_farm,
		patterns = { "" },
		fallback = true,
	}

	-- Nix (dotfiles' home/packages.nix) installs a Lua 5.1-linked luarocks,
	-- replacing the machine's old, lua5.2-linked /usr/local/bin/luarocks.
	-- Point lazy.nvim at it instead of hererocks building its own private
	-- Lua + luarocks under ~/.local/share/nvim/lazy-rocks -- see this repo's
	-- README ("Luarocks / hererocks") for what this works around.
	opts.rocks = {
		hererocks = false,
	}
end

require("lazy").setup({ { import = "mathieu.plugins" } }, opts)

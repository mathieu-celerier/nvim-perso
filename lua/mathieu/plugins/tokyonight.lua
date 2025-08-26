-- #######################################################
-- #                                                     #
-- #                    TokyoNight                       #
-- #                                                     #
-- #######################################################

return {
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			local bg = "#0E0E16"
			local bg_dark = "#0A0A12"
			local bg_highlight = "#0F1B24"
			local bg_search = "#0B5B99"
			-- local bg_visual = "#275378"
			local fg = "#C3CAF4"
			local fg_dark = "#A4A7C9"
			-- local fg_gutter = "#627E97"
			local border = "#1E7BC2"

			require("tokyonight").setup({
				style = "night",
				on_colors = function(colors)
					colors.bg = bg
					colors.bg_dark = bg_dark
					colors.bg_float = bg_dark
					colors.bg_highlight = bg_highlight
					colors.bg_popup = bg_dark
					colors.bg_search = bg_search
					colors.bg_sidebar = bg_dark
					colors.bg_statusline = bg_dark
					--   colors.bg_visual = bg_visual
					colors.border = border
					colors.fg = fg
					colors.fg_dark = fg_dark
					colors.fg_float = fg
					--   colors.fg_gutter = fg_gutter
					colors.fg_sidebar = fg_dark
				end,
				on_highlights = function(hl, c)
					hl["@neorg.markup.italic"] = { fg = "#6F6F6F", italic = true }
					hl["@neorg.headings.1.title"] = { fg = c.yellow }
					hl["@neorg.headings.1.prefix"] = { fg = c.yellow }
					hl["@neorg.headings.2.title"] = { fg = c.cyan }
					hl["@neorg.headings.2.prefix"] = { fg = c.cyan }
					hl["@neorg.headings.3.title"] = { fg = c.green }
					hl["@neorg.headings.3.prefix"] = { fg = c.green }
					hl["@neorg.headings.4.title"] = { fg = c.red }
					hl["@neorg.headings.4.prefix"] = { fg = c.red }
					hl["@neorg.headings.5.title"] = { fg = c.blue }
					hl["@neorg.headings.5.prefix"] = { fg = c.blue }
				end,
			})
			-- load the colorscheme here
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}

-- #######################################################
-- #                                                     #
-- #            Github Dark High Contrast                #
-- #                                                     #
-- #######################################################

-- return {
-- 	"projekt0n/github-nvim-theme",
-- 	lazy = false, -- make sure we load this during startup if it is your main colorscheme
-- 	priority = 1000, -- make sure to load this before all the other start plugins
-- 	config = function()
-- 		require("github-theme").setup({
-- 			-- ...
-- 		})
--
-- 		vim.cmd("colorscheme github_dark_high_contrast")
-- 	end,
-- }

-- #######################################################
-- #                                                     #
-- #                    Catppuccin                       #
-- #                                                     #
-- #######################################################

-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	priority = 1000,
-- 	config = function()
-- 		require("catppuccin").setup({
-- 			color_overrides = {
-- 				mocha = {
-- 					rosewater = "#efc9c2",
-- 					flamingo = "#ebb2b2",
-- 					pink = "#f2a7de",
-- 					mauve = "#b889f4",
-- 					red = "#ea7183",
-- 					maroon = "#ea838c",
-- 					peach = "#f39967",
-- 					yellow = "#eaca89",
-- 					green = "#96d382",
-- 					teal = "#78cec1",
-- 					sky = "#91d7e3",
-- 					sapphire = "#68bae0",
-- 					blue = "#739df2",
-- 					lavender = "#a0a8f6",
-- 					text = "#b5c1f1",
-- 					subtext1 = "#a6b0d8",
-- 					subtext0 = "#959ec2",
-- 					overlay2 = "#848cad",
-- 					overlay1 = "#717997",
-- 					overlay0 = "#63677f",
-- 					surface2 = "#505469",
-- 					surface1 = "#3e4255",
-- 					surface0 = "#2c2f40",
-- 					base = "#1a1c2a",
-- 					mantle = "#141620",
-- 					crust = "#0e0f16",
-- 				},
-- 			},
-- 		})
-- 		-- load the colorscheme here
-- 		vim.cmd([[colorscheme catppuccin]])
-- 	end,
-- }

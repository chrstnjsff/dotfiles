local transparent = true

local coolnight = {
  bg = "#011323",
  bg_dark = "#00111E",
  bg_float = "#00111E",
  bg_highlight = "#012646",
  bg_popup = "#00111E",
  bg_search = "#3E90D7",
  bg_sidebar = "#00111E",
  bg_statusline = "#00111E",
  bg_visual = "#064984",
  fg = "#E3EEF7",
  fg_dark = "#AECBE5",
  fg_float = "#CBDFF0",
  fg_gutter = "#2D4F6C",
  fg_sidebar = "#AECBE5",
  border = "#03447C",
}

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "storm",
      transparent = transparent,
      styles = {
        sidebars = transparent and "transparent" or "dark",
        floats = transparent and "transparent" or "dark",
      },
      on_colors = function(colors)
        colors.bg = coolnight.bg
        colors.bg_dark = transparent and colors.none or coolnight.bg_dark
        colors.bg_float = transparent and colors.none or coolnight.bg_float
        colors.bg_highlight = coolnight.bg_highlight
        colors.bg_popup = coolnight.bg_popup
        colors.bg_search = coolnight.bg_search
        colors.bg_sidebar = transparent and colors.none or coolnight.bg_sidebar
        colors.bg_statusline = transparent and colors.none or coolnight.bg_statusline
        colors.bg_visual = coolnight.bg_visual
        colors.border = coolnight.border
        colors.fg = coolnight.fg
        colors.fg_dark = coolnight.fg_dark
        colors.fg_float = coolnight.fg_float
        colors.fg_gutter = coolnight.fg_gutter
        colors.fg_sidebar = coolnight.fg_sidebar
      end,
      lualine_bold = true,
    },
  },
}

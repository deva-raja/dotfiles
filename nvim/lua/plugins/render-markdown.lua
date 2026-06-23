local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = not is_minimal,
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        enabled = true,
        icons = {},        -- no "①②③"-style level icons before heading text
        signs = {},         -- no heading glyph in the sign column
        backgrounds = {},   -- removes the per-level colored pill background entirely
        border = false,
      },
      bullet = {
        icons = { "-" },        -- plain hyphen instead of colored dot, all levels
        ordered_icons = { "-" },
        left_pad = 0,
        right_pad = 1,
      },
      quote = {
        icon = "│",          -- thin bar instead of thick block icon
      },
      checkbox = {
        unchecked = { icon = "☐ " },
        checked = { icon = "☑ " },
      },
      code = {
        border = "thin",     -- subtle border instead of full background fill
      },
      dash = {
        icon = "─",
      },
    },
  },
}

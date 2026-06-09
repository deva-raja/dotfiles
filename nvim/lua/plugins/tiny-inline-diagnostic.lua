return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- Load early
    config = function()
      -- Disable default virtual text to avoid duplication
      vim.diagnostic.config({ virtual_text = false })

      require("tiny-inline-diagnostic").setup({
        preset = "modern", -- premium style matching the theme perfectly
        options = {
          show_source = true,
          use_icons_from_diagnostic = true,
        },
      })
    end,
  },
}

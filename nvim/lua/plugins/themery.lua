return {
  {
    "zaldih/themery.nvim",
    cmd = "Themery",
    keys = {
      { "<leader>th", "<cmd>Themery<cr>", desc = "Theme: Pick colorscheme" },
    },
    config = function()
      require("themery").setup({
        themes = { "rose-pine-moon", "kanagawa-dragon", "kanagawa-wave", "kanagawa-lotus" },
        livePreview = true,
      })
    end,
  },
}

local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = not is_minimal,
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
}

local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- Enable only the dashboard
      dashboard = { enabled = true },

      -- Explicitly disable all other modules
      bigfile = { enabled = false },
      bufdelete = { enabled = false },
      dim = { enabled = false },
      explorer = { enabled = false },
      git = { enabled = false },
      gitbrowse = { enabled = false },
      image = { enabled = not is_minimal },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      profiler = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scratch = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      terminal = { enabled = false },
      toggle = { enabled = false },
      words = { enabled = false },
      zen = { enabled = false },
    },
  },
}

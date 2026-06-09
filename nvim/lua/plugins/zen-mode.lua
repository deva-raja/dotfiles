return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = 120,
        options = {
          number = false,
          relativenumber = false,
        },
      },
      plugins = {
        gitsigns = { enabled = true },
        tmux = { enabled = false },
        twilight = { enabled = false },
      },
    },
  }
}

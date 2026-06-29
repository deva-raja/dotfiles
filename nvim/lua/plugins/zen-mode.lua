return {
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = 0.55, -- fraction of editor width (zen-mode treats <= 1 as a percentage)
        options = {
          number = false,
          relativenumber = false,
          wrap = true,
        },
      },
      plugins = {
        gitsigns = { enabled = true },
        tmux = { enabled = false },
        twilight = { enabled = false },
      },
    },
  },
}

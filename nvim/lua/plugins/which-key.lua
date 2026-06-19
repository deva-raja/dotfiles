return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- Default triggers are "nxso" (normal, visual, select, operator-pending).
      -- Drop "x" so the popup doesn't show up just from entering Visual mode.
      triggers = {
        { "<auto>", mode = "nso" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Help: Buffer Local Keymaps (Which-Key)",
      },
    },
  },
}

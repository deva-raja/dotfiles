return {
{
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {
    modes = {
      char = {
        enabled = false, -- Disable flash overrides for f, F, t, T
      },
    },
  },
  keys = {
    { "s", mode = { "n" }, function() require("flash").jump({ search = { forward = true } }) end, desc = "Flash: Jump Forward" },
    { "S", mode = { "n" }, function() require("flash").jump({ search = { forward = false } }) end, desc = "Flash: Jump Backward" },
  },
}
}

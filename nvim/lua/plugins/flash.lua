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
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump({ search = { forward = true } }) end, desc = "Flash: Jump Forward" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").jump({ search = { forward = false } }) end, desc = "Flash: Jump Backward" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Flash: Remote Jump" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash: Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Flash: Toggle Search" },
  },
}
}

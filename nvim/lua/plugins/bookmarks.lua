return {
  {
    "crusj/bookmarks.nvim",
    branch = "main",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("bookmarks").setup({
        -- crusj/bookmarks.nvim configuration
        storage_dir = vim.fn.stdpath("data") .. "/bookmarks", -- Where to store bookmarks
        mappings_enabled = true, -- Enable standard list navigation keys
        keymap = {
          toggle = "<tab><tab>", -- Toggle bookmark list window
          add = "\\z",          -- Add bookmark mapping
        },
        width = 0.8, -- Width of the window
        height = 0.7, -- Height of the window
      })
      -- Load telescope extension
      require("telescope").load_extension("bookmarks")
    end,
  }
}

return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000, -- load this before other start plugins
    config = function()
      require("rose-pine").setup({
        variant = "moon", -- use the Moon variant
        dark_variant = "moon",
        styles = {
          bold = true,
          italic = true,
          transparency = true,
        },
      })
      vim.cmd("colorscheme rose-pine-moon")
    end,
  }
}

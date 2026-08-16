return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    lazy = false,
    init = function()
      -- Map gb to select next occurrence in Normal and Visual mode
      vim.g.VM_maps = {
        ["Find Under"] = "gb",
        ["Find Subword Under"] = "gb",
        ["Skip Region"] = "gB",
        ["Visual All"] = "<leader>mA",
      }
      vim.g.VM_theme = "iceblue"
    end,
  },
}

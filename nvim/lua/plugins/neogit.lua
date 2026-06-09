return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    opts = {
      diff_viewer = "codediff",
      integrations = {
        codediff = true,
      },
    },
  }
}

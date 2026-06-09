return {
  {
    'akinsho/bufferline.nvim',
    enabled = false,
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    opts = {
      options = {
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          }
        }
      }
    }
  }
}

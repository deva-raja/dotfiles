return {
  {
    "numToStr/Comment.nvim",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Monkey-patch ft.calculate to handle Neovim 0.12 nil treesitter parser
      local ft = require("Comment.ft")
      local original_calculate = ft.calculate
      ft.calculate = function(ctx)
         local ok, parser = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
         if not ok or not parser then
            return ft.get(vim.bo.filetype, ctx.ctype)
         end
         return original_calculate(ctx)
      end

      require("Comment").setup({
        -- Hook to support context-aware commenting in TSX/JSX buffers
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
}

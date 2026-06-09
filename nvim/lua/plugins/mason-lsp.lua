return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      local lspconfig = require('lspconfig')

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "html", "cssls", "jsonls" },
        handlers = {
          function(server_name)
            -- Apply standard capabilities to every server
            lspconfig[server_name].setup({
              capabilities = capabilities
            })
          end,
        }
      })
    end
  }
}

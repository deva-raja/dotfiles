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

      local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1
      local ensure_installed = { "lua_ls" }
      if not is_minimal then
        vim.list_extend(ensure_installed, { "ts_ls", "html", "cssls", "jsonls" })
      end

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
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

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = nil, -- Explicitly disable format-on-save for auto-save compatibility
    },
  }
}

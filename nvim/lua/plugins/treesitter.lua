return {
   {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      config = function()
         require('nvim-treesitter').setup({
            -- A list of parser names, or "all"
            ensure_installed = { "lua", "vim", "vimdoc", "javascript", "typescript", "tsx", "html", "css", "json", "markdown" },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            auto_install = true,

            highlight = {
               enable = true,
               -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
               -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
               -- Using this option may slow down your editor, and you may see some duplicate highlights.
               additional_vim_regex_highlighting = false,
            },

            indent = {
               enable = true,
            },

            incremental_selection = {
               enable = true,
               keymaps = {
                  init_selection = "af",
                  node_incremental = "af",
                  scope_incremental = "<Tab>",
                  node_decremental = "<BS>",
               },
            },
         })
      end
   }
}

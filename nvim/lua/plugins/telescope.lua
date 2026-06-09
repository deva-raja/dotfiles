return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')

      telescope.setup({
        defaults = {
          path_display = { "truncate" },
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<A-BS>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<M-BS>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<A-Backspace>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<M-Backspace>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<Esc><BS>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<Esc><Backspace>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<Esc><C-h>"] = function() vim.api.nvim_input("<C-w>") end,
              ["<Esc><C-?>"] = function() vim.api.nvim_input("<C-w>") end,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })

      -- Load the fzf C-sorter extension for lightning-fast, space-separated fuzzy searching
      telescope.load_extension('fzf')
    end
  }
}

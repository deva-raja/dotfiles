return {
   {
      'nvim-treesitter/nvim-treesitter',
      branch = 'main',
      lazy = false,
      build = ':TSUpdate',
      config = function()
         -- A list of parser names, or "all"
         local parsers = { "lua", "vim", "vimdoc", "markdown" }
         local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1
         if not is_minimal then
            vim.list_extend(parsers, { "javascript", "typescript", "tsx", "html", "css", "json", "yaml" })
         end

         -- Install missing parsers (no-op for ones already installed)
         require('nvim-treesitter').install(parsers)

         -- Auto-install parsers for languages that aren't pre-installed
         require('nvim-treesitter.configs').setup({
            auto_install = not is_minimal,
         })

         -- Neovim core provides highlighting/indent once a parser exists for the
         -- buffer's language; the plugin itself no longer enables these automatically.
         vim.api.nvim_create_autocmd('FileType', {
            callback = function(args)
               local ok = pcall(vim.treesitter.start, args.buf)
               if ok then
                  vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
               end
            end,
         })
      end
   }
}

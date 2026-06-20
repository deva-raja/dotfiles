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
         local ts = require('nvim-treesitter')
         local installed = ts.get_installed()
         local to_install = {}
         for _, p in ipairs(parsers) do
            if not vim.tbl_contains(installed, p) then
               table.insert(to_install, p)
            end
         end
         if #to_install > 0 then
            ts.install(to_install)
         end

         -- Neovim core provides highlighting/indent once a parser exists for the
         -- buffer's language; the plugin itself no longer enables these automatically.
         vim.api.nvim_create_autocmd('FileType', {
            callback = function(args)
               local filetype = args.match
               local lang = vim.treesitter.language.get_lang(filetype) or filetype
               if lang and not is_minimal then
                  local available_langs = ts.get_available()
                  if vim.tbl_contains(available_langs, lang) then
                     local installed_langs = ts.get_installed()
                     if not vim.tbl_contains(installed_langs, lang) then
                        pcall(function()
                           ts.install(lang):wait()
                        end)
                     end
                  end
               end

               local ok = pcall(vim.treesitter.start, args.buf)
               if ok then
                  vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
               end
            end,
         })
      end
   }
}

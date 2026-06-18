return {
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("spectre").setup({
        mapping = {
          ["run_current_replace"] = {
            map = "r",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "Spectre: Replace Item",
          },
          ["run_replace"] = {
            map = "R",
            cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
            desc = "Spectre: Replace All",
          },
        },
      })

      -- Override get_path_args on the loaded rg search engine module.
      -- This ensures that negative globs for ignored directories are always appended
      -- after the user's path filters, preventing ripgrep's -g flag from bypassing
      -- standard gitignore rules for hidden/ignored folders (like .next, node_modules).
      local rg = require("spectre.search.rg")
      rg.get_path_args = function(_, paths)
        if #paths == 0 then
          return {}
        end

        local args = {}
        for _, path in ipairs(paths) do
          table.insert(args, "-g")
          table.insert(args, path)
        end

        -- Explicitly append negative globs at the end to override any parent directory match
        table.insert(args, "-g")
        table.insert(args, "!**/.next/**")
        table.insert(args, "-g")
        table.insert(args, "!**/node_modules/**")
        table.insert(args, "-g")
        table.insert(args, "!**/.turbo/**")
        table.insert(args, "-g")
        table.insert(args, "!**/dist/**")
        table.insert(args, "-g")
        table.insert(args, "!**/coverage/**")

        return args
      end

      -- Override select_entry to open files in a separate buffer/window
      -- and prevent it from replacing the Spectre window, especially when
      -- opened from a sidebar like Neo-tree.
      local actions = require("spectre.actions")
      local state = require("spectre.state")
      
      actions.select_entry = function()
        local t = actions.get_current_entry()
        if t == nil then
          return nil
        end

        local current_win = vim.api.nvim_get_current_win()
        local target_win = state.target_winid

        local function is_special_win(win)
          if not vim.api.nvim_win_is_valid(win) then return true end
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          local bt = vim.api.nvim_get_option_value("buftype", { buf = buf })
          return ft == "neo-tree" or ft == "NvimTree" or ft == "spectre_panel" or bt == "nofile"
        end

        -- If target window is invalid or is a sidebar/spectre itself, find/create a clean editor window
        if target_win == nil or is_special_win(target_win) then
          target_win = nil
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if not is_special_win(win) then
              target_win = win
              break
            end
          end
        end

        -- If no clean editor window exists, create a new vertical split
        if target_win == nil then
          vim.cmd("vsplit")
          target_win = vim.api.nvim_get_current_win()
          -- Go back to Spectre window so focus behavior is predictable
          vim.fn.win_gotoid(current_win)
        end

        -- Switch to the target window and open the file
        vim.fn.win_gotoid(target_win)
        vim.api.nvim_command([[execute "normal! m` "]])
        local escaped_filename = vim.fn.fnameescape(t.filename)
        vim.cmd("e " .. escaped_filename)
        pcall(vim.api.nvim_win_set_cursor, 0, { t.lnum, t.col })
      end
    end,
  }
}

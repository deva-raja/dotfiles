return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require("mini.surround").setup()
      require("mini.pairs").setup()


      require("mini.indentscope").setup({
        symbol = "│",
      })

      require("mini.move").setup()

      require("mini.splitjoin").setup()

      local minimap = require("mini.map")
      minimap.setup({
        integrations = {
          minimap.gen_integration.builtin_search(),
          minimap.gen_integration.gitsigns(),
          minimap.gen_integration.diagnostic(),
        },
        symbols = {
          encode = minimap.gen_encode_symbols.dot("3x2"),
          scroll_line = "",
          scroll_view = "█",
        },
        window = {
          side = "right",
          width = 15,
          winblend = 15,
          show_integration_count = false,
        },
      })

      -- Custom highlights for mini.map to make it look premium and blend with the theme
      local function set_minimap_hl()
        -- Use theme's Comment color for code outline dots, transparent background
        vim.api.nvim_set_hl(0, "MiniMapNormal", { link = "Comment", bg = "NONE" })
        
        -- Use theme's Visual selection background color for the scrollbar view block
        local visual_hl = vim.api.nvim_get_hl(0, { name = "Visual" })
        local view_color = visual_hl.bg or visual_hl.fg or "#5c6370"
        vim.api.nvim_set_hl(0, "MiniMapSymbolView", { fg = view_color, bg = "NONE" })
      end

      set_minimap_hl()

      -- Ensure highlights stay correct when switching themes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = set_minimap_hl,
      })

      -- Monkey-patch window height calculations for mini.map to make it dynamic height (like VSCode)
      -- capped at 50% of the screen height.
      local function adjust_minimap_opts(buf, opts)
        if opts.relative == 'editor' and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'minimap' then
          local source_buf = minimap.current.buf_data.source or vim.api.nvim_get_current_buf()
          local source_lines = vim.api.nvim_buf_is_valid(source_buf) and vim.api.nvim_buf_line_count(source_buf) or 1
          
          local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
          local has_statusline = vim.o.laststatus > 0
          local max_avail_height = vim.o.lines - vim.o.cmdheight - (has_tabline and 1 or 0) - (has_statusline and 1 or 0)
          
          -- Dynamic height capped at 50% of the screen height (minimap lines are 1 per 3 lines of source code)
          local max_height = math.floor(max_avail_height * 0.5)
          local needed_height = math.ceil(source_lines / 3)
          opts.height = math.max(5, math.min(max_height, needed_height))
        end
      end

      local orig_open_win = vim.api.nvim_open_win
      vim.api.nvim_open_win = function(buf, focus, opts)
        adjust_minimap_opts(buf, opts)
        local win_id = orig_open_win(buf, focus, opts)
        if opts.relative == 'editor' and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'minimap' then
          vim.wo[win_id].winhighlight = "Normal:MiniMapNormal,NormalFloat:MiniMapNormal"
        end
        return win_id
      end

      local orig_win_set_config = vim.api.nvim_win_set_config
      vim.api.nvim_win_set_config = function(win, opts)
        if vim.api.nvim_win_is_valid(win) then
          local buf = vim.api.nvim_win_get_buf(win)
          adjust_minimap_opts(buf, opts)
        end
        return orig_win_set_config(win, opts)
      end

      -- Automatically open MiniMap on startup/file load
      vim.api.nvim_create_autocmd({ "VimEnter", "BufWinEnter" }, {
        desc = "Auto-open MiniMap for normal files",
        callback = function(event)
          local buf = event.buf
          if not buf or not vim.api.nvim_buf_is_valid(buf) then
            return
          end

          -- Skip auto-opening minimap in minimal/headless environments (e.g. SSH)
          local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1
          if is_minimal then
            return
          end

          local file = event.file
          -- Check if buffer is a normal file
          if file == "" or vim.bo[buf].buftype ~= "" then
            return
          end
          local filetype = vim.bo[buf].filetype
          if vim.tbl_contains({ "gitcommit", "gitrebase", "NeogitStatus", "codediff-explorer", "codediff-history", "TelescopePrompt", "noice", "notify" }, filetype) then
            return
          end
          
          -- Wait a tiny bit so window layout is settled
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(buf) then
              pcall(minimap.open)
            end
          end)
        end,
      })
    end,
  },
}

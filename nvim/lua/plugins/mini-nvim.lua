return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require("mini.surround").setup({
        mappings = {
          add = "ys",            -- Add surrounding in Normal and Visual modes
          delete = "ds",         -- Delete surrounding
          find = "sf",           -- Find surrounding (to the right)
          find_left = "sF",      -- Find surrounding (to the left)
          highlight = "sh",      -- Highlight surrounding
          replace = "cs",        -- Replace surrounding
          update_n_lines = "sn", -- Update `n_lines`
        },
      })
      require("mini.pairs").setup()

      -- Visual mode: "s" surrounds the selection (frees "s" from flash.nvim's
      -- visual-mode jump so it behaves like tpope/vim-surround's "S").
      -- Must go through the command-line (:<C-u>) so the '<,'> marks are
      -- committed before mini.surround reads them; a direct Lua callback
      -- exits visual mode first and surrounds the wrong range.
      vim.keymap.set("x", "s", [[:<C-u>lua require('mini.surround').add('visual')<CR>]], { silent = true, desc = "Add surrounding to selection" })


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
          scroll_line = "─",
          scroll_view = "█",
        },
        window = {
          side = "right",
          width = 15,
          winblend = 0, -- Set to 0 to support fully transparent background without black bars
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

        -- Link the current cursor line symbol highlight to CursorLineNr
        vim.api.nvim_set_hl(0, "MiniMapSymbolLine", { link = "CursorLineNr" })
      end

      set_minimap_hl()

      -- Ensure highlights stay correct when switching themes
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = set_minimap_hl,
      })

      -- Monkey-patch window height calculations for mini.map to prevent overlapping
      -- bottom terminal splits (ToggleTerm or terminal buffer).
      local function adjust_minimap_opts(buf, opts)
        if opts.relative == 'editor' and vim.api.nvim_buf_is_valid(buf) and (vim.bo[buf].filetype == 'minimap' or vim.api.nvim_buf_get_name(buf):match("minimap")) then
          local has_tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
          local has_statusline = vim.o.laststatus > 0
          local start_row = has_tabline and 1 or 0
          local max_height = vim.o.lines - vim.o.cmdheight - start_row - (has_statusline and 1 or 0)

          -- Scan all windows in the current tabpage for ToggleTerm or terminal splits at the bottom
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if vim.api.nvim_win_is_valid(win) then
              local win_buf = vim.api.nvim_win_get_buf(win)
              local filetype = vim.bo[win_buf].filetype
              local buftype = vim.bo[win_buf].buftype
              if filetype == 'toggleterm' or buftype == 'terminal' then
                local pos = vim.api.nvim_win_get_position(win)
                local row = pos[1] -- 0-indexed row of the window start
                -- If this terminal window is below the start row, restrict minimap height to stop right above it
                if row > start_row and row < (max_height + start_row) then
                  max_height = row - start_row
                end
              end
            end
          end

          opts.height = math.max(1, max_height)
        end
      end

      local orig_open_win = vim.api.nvim_open_win
      vim.api.nvim_open_win = function(buf, focus, opts)
        adjust_minimap_opts(buf, opts)
        local win_id = orig_open_win(buf, focus, opts)
        if opts.relative == 'editor' and vim.api.nvim_buf_is_valid(buf) and (vim.bo[buf].filetype == 'minimap' or vim.api.nvim_buf_get_name(buf):match("minimap")) then
          vim.wo[win_id].winhighlight = "Normal:MiniMapNormal,NormalFloat:MiniMapNormal,EndOfBuffer:MiniMapNormal"
          vim.wo[win_id].winblend = 0 -- Ensure background is fully transparent
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

      -- Refresh minimap when terminal/ToggleTerm opens or closes to update layout
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "WinClosed", "FileType" }, {
        pattern = "*",
        callback = function()
          -- Use a defer to run after window layout has stabilized
          vim.defer_fn(function()
            pcall(minimap.refresh)
          end, 10)
        end,
      })

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

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>vn", "<cmd>Obsidian new<cr>", desc = "Obsidian: New Note" },
      { "<leader>vo", "<cmd>Obsidian search<cr>", desc = "Obsidian: Search Notes" },
      { "<leader>vs", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian: Quick Switch" },
      { "<leader>vb", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian: Show Backlinks" },
      { "<leader>vt", "<cmd>Obsidian template<cr>", desc = "Obsidian: Insert Template" },
      { "<leader>vi", "<cmd>Obsidian paste_img<cr>", desc = "Obsidian: Paste Image" },
      { "<leader>vl", "<cmd>Obsidian link<cr>", mode = "v", desc = "Obsidian: Link Selection" },
      { "<leader>vl", "<cmd>Obsidian link_new<cr>", mode = "n", desc = "Obsidian: Link to New Note" },
      { "<leader>vf", "<cmd>Obsidian follow_link<cr>", desc = "Obsidian: Follow Link" },
    },
    init = function()
      -- Automatically create the personal vault directory if it doesn't exist
      local personal_vault = vim.fn.expand("~/Documents/Obisidian")
      if vim.fn.isdirectory(personal_vault) == 0 then
        pcall(vim.fn.mkdir, personal_vault, "p")
      end
    end,
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/Obisidian",
        },
        -- Dynamic workspace for files outside defined vaults to avoid warnings
        {
          name = "no-vault",
          path = function()
            -- Returns the parent directory of the current buffer
            return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
          end,
          overrides = {
            notes_subdir = vim.NIL,
            new_notes_location = "current_dir",
            templates = {
              folder = vim.NIL,
            },
            frontmatter = { enabled = false },
          },
        },
      },

      -- Use render-markdown.nvim instead of built-in obsidian.nvim UI to avoid overlap/conflicts
      ui = {
        enable = false,
      },

      -- Disable built-in footer to use our custom logic
      footer = {
        enabled = false,
      },

      -- Configure search/fuzzy finder picker
      picker = {
        name = "telescope.nvim",
      },

      -- Specify where to put daily notes
      daily_notes = {
        folder = "dailies",
        date_format = "%Y-%m-%d",
        alias_format = "%B %d, %Y",
        default_tags = { "daily-notes" },
        template = nil,
      },

      -- New-style "Obsidian <subcommand>" commands only (legacy PascalCase
      -- commands are removed in obsidian.nvim 4.0; see wiki/Commands).
      legacy_commands = false,

      -- Frontmatter management: disabled by default, custom structure when enabled.
      frontmatter = {
        enabled = false,
        func = function(note)
          -- Add the title of the note as an alias
          if note.title then
            note:add_alias(note.title)
          end

          local out = { id = note.id, aliases = note.aliases, tags = note.tags }

          -- Keep existing frontmatter fields
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,
      },

      callbacks = {
        -- Replaces the deprecated `mappings` option (see wiki/Keymaps):
        -- buffer-local keymaps are now set per-note via this callback.
        -- 'gf' follows links/checkboxes/tags, matching the old gf_passthrough.
        enter_note = function()
          vim.keymap.set("n", "gf", require("obsidian.api").smart_action, {
            buffer = true,
            expr = true,
            desc = "Obsidian: Follow link/checkbox/tag",
          })
        end,
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- Custom footer setup (only renders if backlinks > 0, listing the backlinks)
      local ns_id = vim.api.nvim_create_namespace("obsidian.custom_footer")
      local Note = require("obsidian.note")
      local attached_bufs = {}
      local timers = {}

      local function update_custom_footer(buf)
        if not vim.api.nvim_buf_is_valid(buf) then return end
        local note = Note.from_buffer(buf)
        if not note then return end

        note:status(true, function(status)
          if not status then return end
          if not vim.api.nvim_buf_is_valid(buf) then return end

          if status.backlinks == 0 then
            vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
            return
          end

          note:backlinks_async({}, function(matches)
            if not vim.api.nvim_buf_is_valid(buf) then return end

            local status_text = string.format(
              "%d backlinks  %d properties  %d words  %d chars",
              status.backlinks, status.properties, status.words, status.chars
            )

            local separator = string.rep("-", 80)
            local footer_lines = {
              { { separator, "Comment" } },
              { { status_text, "Comment" } }
            }

            local backlink_names = {}
            local seen = {}
            for _, match in ipairs(matches) do
              local src_path = match.path
              if src_path then
                local name = vim.fs.basename(tostring(src_path)):gsub("%.md$", "")
                if not seen[name] then
                  seen[name] = true
                  table.insert(backlink_names, name)
                end
              end
            end

            if #backlink_names > 0 then
              local backlinks_str = "Backlinks: " .. table.concat(backlink_names, ", ")
              table.insert(footer_lines, { { backlinks_str, "Comment" } })
            end

            local row0 = #vim.api.nvim_buf_get_lines(buf, 0, -2, false)
            local col0 = 0
            local ext_opts = { virt_lines = footer_lines }
            vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
            vim.api.nvim_buf_set_extmark(buf, ns_id, row0, col0, ext_opts)
          end)
        end)
      end

      local function start_custom_footer(buf)
        if attached_bufs[buf] then return end
        attached_bufs[buf] = true

        local group = vim.api.nvim_create_augroup("obsidian.custom-footer-" .. buf, {})

        -- Update on changes
        vim.api.nvim_create_autocmd({
          "FileChangedShellPost",
          "TextChanged",
          "TextChangedI",
          "TextChangedP",
        }, {
          group = group,
          buffer = buf,
          callback = function()
            update_custom_footer(buf)
          end,
        })

        -- Update when cursor moves in visual mode
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = group,
          buffer = buf,
          callback = function()
            if vim.api.nvim_get_mode().mode:lower():find("v") then
              update_custom_footer(buf)
            end
          end,
        })

        -- Periodic update every 10 seconds
        local timer = vim.uv.new_timer()
        timer:start(0, 10000, vim.schedule_wrap(function()
          update_custom_footer(buf)
        end))
        timers[buf] = timer

        -- Cleanup on buffer leave/unload
        vim.api.nvim_create_autocmd({
          "BufWipeout",
          "BufUnload",
          "BufDelete",
        }, {
          group = group,
          buffer = buf,
          callback = function()
            if timers[buf] then
              timers[buf]:stop()
              timers[buf]:close()
              timers[buf] = nil
            end
            attached_bufs[buf] = nil
            pcall(vim.api.nvim_del_augroup_by_id, group)
          end,
        })
      end

      -- Attach custom footer to markdown files on BufReadPost/BufNewFile
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("obsidian.custom-footer-attach", {}),
        pattern = "*.md",
        callback = function(ev)
          vim.schedule(function()
            local api = require("obsidian.api")
            if api.find_workspace(ev.file) then
              start_custom_footer(ev.buf)
            end
          end)
        end,
      })
    end,
  }
}

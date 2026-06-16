return {
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    opts = {
      diff = {
        layout = "inline", -- Inline by default
      },
      explorer = {
        hidden = false, -- visible by default
      },
      keymaps = {
        view = {
          quit = "q",
          toggle_layout = "<D-c>", -- Command + c toggles layout
          show_help = "?",
        }
      }
    },
    config = function(_, opts)
      -- Call the original setup
      require("codediff").setup(opts)

      -- Define status symbols copy
      local STATUS_SYMBOLS = {
        M = { symbol = "M", color = "CodeDiffStatusModified" },
        A = { symbol = "A", color = "CodeDiffStatusAdded" },
        D = { symbol = "D", color = "CodeDiffStatusDeleted" },
        ["??"] = { symbol = "??", color = "CodeDiffStatusUntracked" },
        ["!"] = { symbol = "!", color = "CodeDiffStatusConflict" },
      }

      -- Define indent markers copy
      local INDENT_MARKERS = {
        edge = "│",
        item = "├",
        last = "└",
        none = " ",
      }

      -- Helper to unquote path (from git.lua)
      local function unquote_path(path)
        if not path then return nil end
        if path:sub(1, 1) == '"' and path:sub(-1) == '"' then
          path = path:sub(2, -2)
          path = path:gsub("\\(%d%d%d)", function(octal)
            return string.char(tonumber(octal, 8))
          end)
          path = path:gsub("\\(.)", "%1")
        end
        return path
      end

      -- Helper to check for conflicts (from git.lua)
      local function is_conflict_status(index_status, worktree_status)
        if index_status == "U" or worktree_status == "U" then return true end
        if index_status == "A" and worktree_status == "A" then return true end
        if index_status == "D" and worktree_status == "D" then return true end
        return false
      end

      -- Helper to run diff --numstat asynchronously
      local function run_numstat(git_root, diff_args, callback)
        vim.schedule(function()
          local cmd = { "git", "-C", git_root, "diff", "--numstat", "-M" }
          for _, arg in ipairs(diff_args) do
            table.insert(cmd, arg)
          end

          local stdout = {}
          vim.fn.jobstart(cmd, {
            stdout_buffered = true,
            on_stdout = function(_, data)
              if data then
                for _, line in ipairs(data) do
                  if line ~= "" then
                    table.insert(stdout, line)
                  end
                end
              end
            end,
            on_exit = function(_, exit_code)
              local stats = {}
              if exit_code == 0 then
                for _, line in ipairs(stdout) do
                  local ins, del, path = line:match("^([%d%-]+)%s+([%d%-]+)%s+(.+)$")
                  if ins and del and path then
                    local clean_path = path
                    if path:match("{.*=>.*}") then
                      local prefix, old, new, suffix = path:match("^(.*)%{(.-)%s*=>%s*(.-)%}(.*)$")
                      if prefix then
                        if new == "" and prefix:sub(-1) == "/" then
                          prefix = prefix:sub(1, -2)
                        end
                        clean_path = prefix .. new .. suffix
                      end
                    elseif path:match("=>") then
                      local old, new = path:match("^(.+)%s*=>%s*(.+)$")
                      if new then
                        clean_path = new
                      end
                    end
                    stats[clean_path] = { additions = tonumber(ins) or 0, deletions = tonumber(del) or 0 }
                  end
                end
              end
              vim.schedule(function()
                callback(stats)
              end)
            end
          })
        end)
      end

      -- Monkey-patch git.lua
      local git = require("codediff.core.git")
      local orig_get_status = git.get_status
      local orig_get_diff_revision = git.get_diff_revision
      local orig_get_diff_revisions = git.get_diff_revisions

      git.get_status = function(git_root, callback)
        orig_get_status(git_root, function(err, result)
          if err or not result then
            callback(err, result)
            return
          end
          run_numstat(git_root, {}, function(unstaged_stats)
            run_numstat(git_root, { "--cached" }, function(staged_stats)
              for _, file in ipairs(result.staged) do
                local stat = staged_stats[file.path] or { additions = 0, deletions = 0 }
                file.additions = stat.additions
                file.deletions = stat.deletions
              end
              for _, file in ipairs(result.unstaged) do
                local stat = unstaged_stats[file.path] or { additions = 0, deletions = 0 }
                file.additions = stat.additions
                file.deletions = stat.deletions
              end
              callback(nil, result)
            end)
          end)
        end)
      end

      git.get_diff_revision = function(revision, git_root, callback)
        orig_get_diff_revision(revision, git_root, function(err, result)
          if err or not result then
            callback(err, result)
            return
          end
          run_numstat(git_root, { revision }, function(stats)
            for _, file in ipairs(result.unstaged) do
              local stat = stats[file.path] or { additions = 0, deletions = 0 }
              file.additions = stat.additions
              file.deletions = stat.deletions
            end
            callback(nil, result)
          end)
        end)
      end

      git.get_diff_revisions = function(rev1, rev2, git_root, callback)
        orig_get_diff_revisions(rev1, rev2, git_root, function(err, result)
          if err or not result then
            callback(err, result)
            return
          end
          run_numstat(git_root, { rev1, rev2 }, function(stats)
            for _, file in ipairs(result.unstaged) do
              local stat = stats[file.path] or { additions = 0, deletions = 0 }
              file.additions = stat.additions
              file.deletions = stat.deletions
            end
            callback(nil, result)
          end)
        end)
      end

      -- Monkey-patch nodes.lua
      local nodes = require("codediff.ui.explorer.nodes")
      local orig_create_file_nodes = nodes.create_file_nodes
      local orig_create_tree_file_nodes = nodes.create_tree_file_nodes

      nodes.create_file_nodes = function(files, git_root, group)
        local tree_nodes = orig_create_file_nodes(files, git_root, group)
        for i, file in ipairs(files) do
          if tree_nodes[i] and tree_nodes[i].data then
            tree_nodes[i].data.additions = file.additions
            tree_nodes[i].data.deletions = file.deletions
          end
        end
        return tree_nodes
      end

      local function decorate_tree_nodes(tree_nodes, files_map)
        for _, node in ipairs(tree_nodes) do
          if node.data and node.data.path then
            local file_data = files_map[node.data.path]
            if file_data then
              node.data.additions = file_data.additions
              node.data.deletions = file_data.deletions
            end
          end
          if node._children and #node._children > 0 then
            decorate_tree_nodes(node._children, files_map)
          end
        end
      end

      nodes.create_tree_file_nodes = function(files, git_root, group)
        local tree_nodes = orig_create_tree_file_nodes(files, git_root, group)
        local files_map = {}
        for _, file in ipairs(files) do
          files_map[file.path] = file
        end
        decorate_tree_nodes(tree_nodes, files_map)
        return tree_nodes
      end

      -- Custom prepare_node function replacing nodes.prepare_node
      nodes.prepare_node = function(node, max_width, selected_path, selected_group)
        local config = require("codediff.config")
        local Line = require("codediff.ui.lib.line")
        local line = Line()
        local data = node.data or {}
        local explorer_config = config.options.explorer or {}
        local use_indent_markers = explorer_config.indent_markers ~= false

        local function build_indent_markers(indent_state)
          if not indent_state or #indent_state == 0 then return "" end
          if not use_indent_markers then return string.rep("  ", #indent_state) end
          local indent_parts = {}
          for i = 1, #indent_state - 1 do
            if indent_state[i] then
              indent_parts[#indent_parts + 1] = INDENT_MARKERS.none .. " "
            else
              indent_parts[#indent_parts + 1] = INDENT_MARKERS.edge .. " "
            end
          end
          if indent_state[#indent_state] then
            indent_parts[#indent_parts + 1] = INDENT_MARKERS.last .. " "
          else
            indent_parts[#indent_parts + 1] = INDENT_MARKERS.item .. " "
          end
          return table.concat(indent_parts)
        end

        if data.type == "group" then
          line:append(" ", "CodeDiffExplorerTreeGroup")
          line:append(node.text, "CodeDiffExplorerTreeGroup")
        elseif data.type == "directory" then
          local indent = build_indent_markers(data.indent_state)
          local folder_icon, folder_color = nodes.get_folder_icon(node:is_expanded())
          if #indent > 0 then
            line:append(indent, use_indent_markers and "NeoTreeIndentMarker" or "Normal")
          end
          line:append(folder_icon .. " ", folder_color or "Directory")
          line:append(data.name, "Directory")
        else
          local is_selected = data.path and data.path == selected_path and data.group == selected_group
          local selected_bg = nil
          if is_selected then
            local sel_hl = vim.api.nvim_get_hl(0, { name = "CodeDiffExplorerSelected", link = false })
            selected_bg = sel_hl.bg
          end

          local function get_hl(default)
            if not is_selected then return default or "Normal" end
            local base_hl_name = default or "Normal"
            local combined_name = "CodeDiffExplorerSel_" .. base_hl_name:gsub("[^%w]", "_")
            local base_hl = vim.api.nvim_get_hl(0, { name = base_hl_name, link = false })
            vim.api.nvim_set_hl(0, combined_name, { fg = base_hl.fg, bg = selected_bg })
            return combined_name
          end

          local view_mode = explorer_config.view_mode or "list"
          local indent
          if view_mode == "tree" and data.indent_state then
            indent = build_indent_markers(data.indent_state)
            if #indent > 0 then
              line:append(indent, get_hl(use_indent_markers and "NeoTreeIndentMarker" or "Normal"))
            end
          else
            indent = string.rep("  ", node:get_depth() - 1)
            line:append(indent, get_hl("Normal"))
          end

          local icon_part = ""
          if data.icon then
            icon_part = data.icon .. " "
            line:append(icon_part, get_hl(data.icon_color))
          end

          local status_symbol = data.status_symbol or ""
          local full_path = data.path or node.text
          local filename = full_path:match("([^/]+)$") or full_path
          local directory = (view_mode == "tree") and "" or full_path:sub(1, -(#filename + 1))

          local status_margin = config.options.explorer.status_right_margin or 1
          local stats_width = 0
          if (data.additions and data.additions > 0) or (data.deletions and data.deletions > 0) then
            local add_str = data.additions and tostring(data.additions) or "0"
            local del_str = data.deletions and tostring(data.deletions) or "0"
            stats_width = 1 + #add_str + 2 + #del_str
          end

          local used_width = vim.fn.strdisplaywidth(indent) + vim.fn.strdisplaywidth(icon_part) + stats_width
          local status_reserve = vim.fn.strdisplaywidth(status_symbol) + 2 + status_margin
          local available_for_content = max_width - used_width - status_reserve

          local filename_len = vim.fn.strdisplaywidth(filename)
          local directory_len = vim.fn.strdisplaywidth(directory)
          local space_len = (directory_len > 0) and 1 or 0

          if filename_len + space_len + directory_len > available_for_content then
            local available_for_dir = available_for_content - filename_len - space_len
            if available_for_dir > 3 then
              local ellipsis = "..."
              local chars_to_keep = available_for_dir - vim.fn.strdisplaywidth(ellipsis)
              local byte_pos = 0
              local accumulated_width = 0
              for char in vim.gsplit(directory, "") do
                local char_width = vim.fn.strdisplaywidth(char)
                if accumulated_width + char_width > chars_to_keep then break end
                accumulated_width = accumulated_width + char_width
                byte_pos = byte_pos + #char
              end
              directory = directory:sub(1, byte_pos) .. ellipsis
            else
              directory = ""
              space_len = 0
            end
          end

          line:append(filename, get_hl("Normal"))
          if #directory > 0 then
            line:append(" ", get_hl("Normal"))
            line:append(directory, get_hl("ExplorerDirectorySmall"))
          end

          if (data.additions and data.additions > 0) or (data.deletions and data.deletions > 0) then
            line:append(" ", get_hl("Normal"))
            if data.additions and data.additions > 0 then
              line:append(tostring(data.additions), get_hl("CodeDiffStatusAdded"))
            else
              line:append("0", get_hl("Normal"))
            end
            line:append(",", get_hl("Normal"))
            line:append(" ", get_hl("Normal"))
            if data.deletions and data.deletions > 0 then
              line:append(tostring(data.deletions), get_hl("CodeDiffStatusDeleted"))
            else
              line:append("0", get_hl("Normal"))
            end
          end

          local content_len = vim.fn.strdisplaywidth(filename) + space_len + vim.fn.strdisplaywidth(directory)
          local padding_needed = math.max(2, available_for_content - content_len + 2)
          line:append(string.rep(" ", padding_needed), get_hl("Normal"))
          line:append(status_symbol, get_hl(data.status_color))
          if status_margin > 0 then
            line:append(string.rep(" ", status_margin), get_hl("Normal"))
          end
        end

        return line
      end
    end
  }
}

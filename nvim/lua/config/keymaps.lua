-- Keymaps configuration file
-- Organized by category: Core/General, Window Navigation, Splits, Bufferline, Search/Telescope, LSP, Harpoon, Terminal, Zen Mode, etc.

local map = vim.keymap.set
local opts = { silent = true }

-- ==========================================
-- 1. CORE / GENERAL MAPPINGS
-- ==========================================

-- Save file (mimicking VS Code Ctrl+S and Cmd+S)
map("n", "<C-s>", "<cmd>w<CR>", { desc = "File: Save" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "File: Save" })
map("x", "<C-s>", "<cmd>w<CR>gv", { desc = "File: Save" })

map("n", "<D-s>", "<cmd>w<CR>", { desc = "File: Save" })
map("i", "<D-s>", "<Esc>:w<CR>a", { desc = "File: Save" })
map("x", "<D-s>", "<cmd>w<CR>gv", { desc = "File: Save" })

-- Toggle comment (mimicking VS Code Cmd+/)
map("n", "<D-/>", "gcc", { remap = true, desc = "Editor: Toggle Comment Line" })
map("n", "<C-/>", "gcc", { remap = true, desc = "Editor: Toggle Comment Line" })
map("n", "<C-_>", "gcc", { remap = true, desc = "Editor: Toggle Comment Line" })

map("x", "<D-/>", "gc", { remap = true, desc = "Editor: Toggle Comment Selection" })
map("x", "<C-/>", "gc", { remap = true, desc = "Editor: Toggle Comment Selection" })
map("x", "<C-_>", "gc", { remap = true, desc = "Editor: Toggle Comment Selection" })

map("i", "<D-/>", "<Esc>gcca", { remap = true, desc = "Editor: Toggle Comment Line" })
map("i", "<C-/>", "<Esc>gcca", { remap = true, desc = "Editor: Toggle Comment Line" })
map("i", "<C-_>", "<Esc>gcca", { remap = true, desc = "Editor: Toggle Comment Line" })

-- Faster vertical movement (J / K moving 5 lines instead of 1, as configured in VS Code)
map({ "n", "x" }, "J", "5j", { desc = "Navigation: Move Down 5 Lines" })
map({ "n", "x" }, "K", "5k", { desc = "Navigation: Move Up 5 Lines" })

-- Insert line below and return to normal mode (VS Code insertLineAfter)
map("n", "<leader>p", "o<Esc>", { desc = "Editor: Insert Line Below" })

-- Muscle memory helpers from your VS Code Vim settings:
-- gn -> * (search word under cursor)
-- gj -> ^ (start of line)
-- gl -> % (matching bracket/parentheses)
map({ "n", "x", "o" }, "gn", "*", { desc = "Search: Word Under Cursor" })
map({ "n", "x", "o" }, "gj", "^", { desc = "Navigation: Go to Line Start" })
map({ "n", "x", "o" }, "gl", "%", { desc = "Navigation: Go to Matching Bracket" })

-- Invert default jump list navigation:
-- Ctrl+O jumps forward (inbuilt is Ctrl+I)
-- Ctrl+I jumps backward (inbuilt is Ctrl+O)
map("n", "<C-o>", "<C-i>", { desc = "Navigation: Jump Forward in History" })
map("n", "<C-i>", "<C-o>", { desc = "Navigation: Jump Backward in History" })

-- Alternative history navigation using Ctrl+Minus (backward) and Ctrl+Plus/Equal (forward)
map("n", "<C-->", "<C-i>", { remap = true, desc = "Navigation: Jump Backward in History" })
map("n", "<C-+>", "<C-o>", { remap = true, desc = "Navigation: Jump Forward in History" })
map("n", "<C-=>", "<C-o>", { remap = true, desc = "Navigation: Jump Forward in History" })

-- Jump back in jump list (<leader>a -> Ctrl+I which is now backward)
map("n", "<leader>a", "<C-i>", { desc = "Navigation: Jump Backward in History" })

-- Search command mapping (<leader>c -> /)
map("n", "<leader>c", "/", { desc = "Search: Find Pattern Forward" })

-- Clear search highlights on pressing Escape in normal mode
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Search: Clear Highlights" })

-- Close Neovim completely (Quit all). Requires Esc twice so dismissing the
-- which-key popup with a single Esc doesn't accidentally quit.
map("n", "<leader><Esc><Esc>", "<cmd>qa<CR>", { silent = true, desc = "System: Quit Neovim" })

-- Indent/outdent in visual mode keeping selection active (Tab / Shift-Tab)
map("v", "<Tab>", ">gv", { desc = "Editor: Indent Selection" })
map("v", "<S-Tab>", "<gv", { desc = "Editor: Outdent Selection" })

-- Keep cursor centered when jumping to the bottom of the file
map({ "n", "x" }, "G", "Gzz", { desc = "Navigation: Go to Bottom and Center" })

-- Copy selection/line to clipboard (Cmd + C)
map("n", "<D-c>", '"+yy', { desc = "Clipboard: Copy Line" })
map("x", "<D-c>", '"+y', { desc = "Clipboard: Copy Selection" })

-- Yank file path shortcuts for agent CLI and general use
map("n", "<leader>yp", function()
   local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
   if path == "" then
      vim.notify("No file active", vim.log.levels.WARN)
      return
   end
   local formatted = "@" .. path
   vim.fn.setreg("+", formatted)
   vim.notify("Copied: " .. formatted, vim.log.levels.INFO)
end, { desc = "Clipboard: Copy Relative Path with @" })

map("n", "<leader>yP", function()
   local path = vim.api.nvim_buf_get_name(0)
   if path == "" then
      vim.notify("No file active", vim.log.levels.WARN)
      return
   end
   vim.fn.setreg("+", path)
   vim.notify("Copied absolute path: " .. path, vim.log.levels.INFO)
end, { desc = "Clipboard: Copy Absolute Path" })

-- Undo & Redo (Cmd + Z & Cmd + Y)
map("n", "<D-z>", "u", { desc = "Editor: Undo" })
map("i", "<D-z>", "<C-o>u", { desc = "Editor: Undo" })
map("n", "<D-y>", "<C-r>", { desc = "Editor: Redo" })
map("i", "<D-y>", "<C-o><C-r>", { desc = "Editor: Redo" })

-- Alt/Option + Backspace in insert mode to delete word before cursor (Mac bindings)
map("i", "<A-BS>", "<C-w>", { desc = "Editor: Delete word before cursor" })
map("i", "<M-BS>", "<C-w>", { desc = "Editor: Delete word before cursor" })
map("i", "<A-Backspace>", "<C-w>", { desc = "Editor: Delete word before cursor" })
map("i", "<M-Backspace>", "<C-w>", { desc = "Editor: Delete word before cursor" })
map("i", "<Esc><BS>", "<C-w>", { desc = "Editor: Delete word before cursor" })
map("i", "<Esc><Backspace>", "<C-w>", { desc = "Editor: Delete word before cursor" })

-- Toggle Neo-tree sidebar with Command + \ (mimicking VS Code sidebar toggle)
map({ "n", "i", "x" }, "<D-\\>", "<cmd>Neotree toggle reveal<CR>", { desc = "Sidebar: Toggle Neo-tree Explorer" })

-- Toggle comments with Command + / (mimicking VS Code)
map("n", "<D-/>", "gcc", { remap = true, desc = "Editor: Toggle Comment" })
map("x", "<D-/>", "gc", { remap = true, desc = "Editor: Toggle Comment" })


-- ==========================================
-- 2. NAVIGATION & SEARCH
-- ==========================================

-- Horizontal movement mapping (<leader>h/l and <C-h/l>)
map("n", "<leader>h", "<C-w>h", { desc = "Window: Focus Left Window" })
map("n", "<leader>l", "<C-w>l", { desc = "Window: Focus Right Window" })
map("n", "<C-h>", "<C-w>h", { desc = "Window: Focus Left Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Window: Focus Right Window" })

-- Vertical window movement mappings (<leader>j/k and <C-j/k>)
map("n", "<leader>k", "<C-w>k", { desc = "Window: Focus Top Window" })
map("n", "<leader>j", "<C-w>j", { desc = "Window: Focus Bottom Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Window: Focus Top Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Window: Focus Bottom Window" })
map("n", "<D-k>", "<C-w>k", { desc = "Window: Focus Top Window" })


-- ==========================================
-- 3. SPLIT MANAGEMENT
-- ==========================================

map("n", "<leader>fv", "<cmd>vsplit<CR>", { desc = "Window: Split Vertically" })
map("n", "<leader>fh", "<cmd>split<CR>", { desc = "Window: Split Horizontally" })


-- ==========================================
-- 4. BUFFER NAVIGATION (Bufferline)
-- ==========================================

-- Close buffers
map("n", "<leader>w", "<cmd>bdelete<CR>", { desc = "Buffer: Close Active Buffer" })
map("n", "<leader>gc", "<cmd>%bd|e#|bd#<CR>", { desc = "Buffer: Close Other Buffers" })



-- ==========================================
-- 5. SEARCH & NAVIGATION (Telescope)
-- ==========================================

map("n", "<leader>i", function()
   require("telescope.builtin").find_files({
      prompt_title = "Find Files (Incl. Untracked/Env)",
      find_command = {
         "fd",
         "--type", "f",
         "--hidden",
         "--no-ignore",
         "--exclude", ".git",
         "--exclude", "node_modules",
         "--exclude", "dist",
         "--exclude", "generated",
         "--exclude", "build",
         "--exclude", ".next",
      },
   })
end, { desc = "Files: Find File (Git/Workspace)" })
map("n", "<leader>fs", function()
   require("telescope.builtin").live_grep({
      additional_args = function(opts)
         return {
            "--glob", "!**/.git/*",
            "--glob", "!**/node_modules/*",
            "--glob", "!**/dist/*",
            "--glob", "!**/generated/*",
            "--glob", "!**/build/*",
            "--glob", "!**/.next/*",
         }
      end,
   })
end, { desc = "Search: Live Grep (Workspace)" })
map("n", "<leader>;", "<cmd>Telescope keymaps<CR>", { desc = "Command Palette" })
map("n", "<leader>n", "<cmd>Telescope buffers<CR>", { desc = "Buffer: List Open Buffers" })
map("n", "<leader>?", "<cmd>Telescope keymaps<CR>", { desc = "Help: Keymaps Search" })
map("n", "<leader>/", function() require("spectre").toggle() end, { desc = "Search: Global Search & Replace (Spectre)" })
map("n", "af", function()
   vim.cmd("normal! v")
   require("vim.treesitter._select").select_parent()
end, { desc = "Init Treesitter selection" })

map("x", "af", function()
   require("vim.treesitter._select").select_parent()
end, { desc = "Expand Treesitter selection" })


-- ==========================================
-- 6. LSP SYMBOLS & NAVIGATION
-- ==========================================

map("n", "<leader>e", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "LSP: Go to Document Symbol" })
map("n", "<leader>u", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "LSP: Go to Workspace Symbol" })
map("n", "<leader>o", function() require("conform").format({ async = true, lsp_fallback = true }) end,
   { desc = "LSP: Format Document" })


-- ==========================================
-- 7. BOOKMARKS & MINIMAP
-- ==========================================

-- Bookmarks (b for Bookmarks)
map("n", "<leader>ba", function() require("bookmarks").add_bookmarks() end, { desc = "Bookmarks: Add Line Bookmark" })
map("n", "<leader>bt", function() require("bookmarks").toggle_bookmarks() end,
   { desc = "Bookmarks: Toggle Bookmarks List" })

-- Minimap
map("n", "<leader>m", function() require("mini.map").toggle() end, { desc = "Minimap: Toggle" })

-- Markdown rendering
local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or
vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1
if not is_minimal then
   map("n", "<leader>rm", "<cmd>RenderMarkdown toggle<CR>", { desc = "Markdown: Toggle Rendering Preview" })
end


-- ==========================================
-- 8. TERMINAL (ToggleTerm)
-- ==========================================

-- Toggle terminal with <leader>tt or Ctrl+` (same as VS Code)
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Terminal: Toggle Terminal Window" })
map({ "n", "t" }, "<C-`>", "<cmd>ToggleTerm<CR>", { desc = "Terminal: Toggle Terminal Window" })

-- Toggle terminal with Command + j (mimicking VS Code Cmd+J panel toggle)
map({ "n", "i", "t" }, "<D-j>", "<cmd>ToggleTerm<CR>", { desc = "Terminal: Toggle Terminal Window" })

-- Helper function to focus the active terminal buffer
local function focus_terminal()
   local term_module = require("toggleterm.terminal")
   local all_terms = term_module.get_all(true)

   -- Find an open terminal window and jump to it
   for _, term in ipairs(all_terms) do
      if term:is_open() then
         term:focus()
         return
      end
   end

   -- If no terminal is open, open the last focused one or the first one
   local last_focused = term_module.get_last_focused()
   if last_focused then
      last_focused:open()
   else
      vim.cmd("ToggleTerm")
   end
end

-- Focus terminal from editor: Command + m
map({ "n", "i", "v" }, "<D-m>", focus_terminal, { desc = "Terminal: Focus Terminal from Editor" })

-- Helper function to spawn a new ToggleTerm session
local function spawn_new_terminal()
   local term_module = require("toggleterm.terminal")
   local _, current_term = term_module.identify()
   if current_term then
      current_term:close()
   end

   local all_terms = term_module.get_all(true)
   local max_id = 0
   for _, term in ipairs(all_terms) do
      if term.id > max_id then
         max_id = term.id
      end
   end
   local next_id = max_id + 1
   vim.cmd(next_id .. "ToggleTerm")
end

-- Helper function to cycle through active terminals
local function cycle_terminals(direction)
   local term_module = require("toggleterm.terminal")
   local all_terms = term_module.get_all(true)
   if #all_terms <= 1 then
      return
   end

   -- Sort active terminals by their ID
   table.sort(all_terms, function(a, b) return a.id < b.id end)

   -- Find the currently active/focused terminal
   local current_idx = nil
   for i, term in ipairs(all_terms) do
      if term:is_open() and vim.api.nvim_get_current_buf() == term.bufnr then
         current_idx = i
         break
      end
   end

   if not current_idx then
      return
   end

   -- Calculate next index
   local next_idx
   if direction == "next" then
      next_idx = current_idx + 1
      if next_idx > #all_terms then
         next_idx = 1
      end
   else
      next_idx = current_idx - 1
      if next_idx < 1 then
         next_idx = #all_terms
      end
   end

   local current_term = all_terms[current_idx]
   local next_term = all_terms[next_idx]

   if current_term then
      current_term:close()
   end
   next_term:open()
end

-- Helper function to focus any window currently showing a ToggleTerm buffer
local function focus_any_terminal_window()
   local wins = vim.api.nvim_tabpage_list_wins(0)
   for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "toggleterm" then
         vim.api.nvim_set_current_win(win)
         return true
      end
   end
   return false
end

-- Helper function to close the current terminal (fully destroy/shutdown session) and switch to another
local function close_current_terminal()
   local term_module = require("toggleterm.terminal")
   local _, current_term = term_module.identify()
   if current_term then
      local all_terms = term_module.get_all(true)
      -- Sort active terminals by their ID
      table.sort(all_terms, function(a, b) return a.id < b.id end)

      local current_idx = nil
      for i, term in ipairs(all_terms) do
         if term.id == current_term.id then
            current_idx = i
            break
         end
      end

      local next_term = nil
      if current_idx and #all_terms > 1 then
         if current_idx > 1 then
            next_term = all_terms[current_idx - 1]
         else
            next_term = all_terms[current_idx + 1]
         end
      end

      if next_term then
         cycle_terminals("prev")
         vim.schedule(function()
            current_term.window = nil
            current_term:shutdown()
            vim.defer_fn(function()
               focus_any_terminal_window()
            end, 100)
         end)
      else
         current_term:shutdown()
      end
   else
      vim.cmd("bdelete!")
   end
end

-- Helper function to close all terminals (destroys all sessions and UI)
local function close_all_terminals()
   local term_module = require("toggleterm.terminal")
   local all_terms = term_module.get_all(true)
   for _, term in ipairs(all_terms) do
      term:shutdown()
   end
end

-- Helper function to hide the current terminal (keeps session running in background)
local function hide_current_terminal()
   local term_module = require("toggleterm.terminal")
   local _, term = term_module.identify()
   if term then
      term:close()
   else
      vim.cmd("ToggleTerm")
   end
end

-- Helper function to select terminal from picker (with in-place switching)
local function select_terminal_custom()
   local term_module = require("toggleterm.terminal")
   local terminals = term_module.get_all(true)
   if #terminals == 0 then
      vim.notify("No active terminals", vim.log.levels.INFO)
      return
   end

   local _, current_term = term_module.identify()

   vim.ui.select(terminals, {
      prompt = "Select terminal session: ",
      format_item = function(term)
         return term.id .. ": " .. term:_display_name()
      end,
   }, function(choice)
      if not choice then return end
      if current_term and current_term.id ~= choice.id then
         current_term:close()
      end
      choice:open()
   end)
end

-- Terminal-specific buffer keymaps (applied when a terminal opens)
vim.api.nvim_create_autocmd("TermOpen", {
   desc = "Configure keymaps for terminal buffers",
   callback = function(event)
      local bufnr = event.buf
      local opts = { buffer = bufnr, silent = true }

      -- Spin up new terminal session: Command + n or Ctrl + n
      map({ "t", "n" }, "<D-n>", spawn_new_terminal, vim.tbl_extend("force", opts, { desc = "Terminal: New Session" }))
      map({ "t", "n" }, "<C-n>", spawn_new_terminal, vim.tbl_extend("force", opts, { desc = "Terminal: New Session" }))

      -- Cycle previous/next: Command + 8 and Command + 9
      map({ "t", "n" }, "<D-8>", function() cycle_terminals("prev") end,
         vim.tbl_extend("force", opts, { desc = "Terminal: Previous Session" }))
      map({ "t", "n" }, "<D-9>", function() cycle_terminals("next") end,
         vim.tbl_extend("force", opts, { desc = "Terminal: Next Session" }))

      -- Select picker: Command + ;
      map({ "t", "n" }, "<D-;>", select_terminal_custom,
         vim.tbl_extend("force", opts, { desc = "Terminal: Select Session" }))

      -- Focus editor back from terminal with Command + m
      map({ "t", "n" }, "<D-m>", [[<C-\><C-n><C-w>p]],
         vim.tbl_extend("force", opts, { desc = "Terminal: Focus Editor Window" }))

      -- Resize terminal: Command + ] to increase height, Command + [ to decrease height
      -- (Command+Shift+[/] is reserved by macOS for native tab switching and can't be
      -- unbound from Ghostty, so resize uses the unshifted bracket keys instead.)
      map({ "t", "n" }, "<D-[>", "<cmd>resize -2<CR>",
         vim.tbl_extend("force", opts, { desc = "Terminal: Decrease Window Height" }))
      map({ "t", "n" }, "<D-]>", "<cmd>resize +2<CR>",
         vim.tbl_extend("force", opts, { desc = "Terminal: Increase Window Height" }))

      -- Close terminal with 'q' in normal mode inside terminal buffer (destroys process)
      map("n", "q", close_current_terminal, vim.tbl_extend("force", opts, { desc = "Terminal: Close Current Session" }))

      -- Close all terminals with 'Q' in normal mode inside terminal buffer (destroys all processes)
      map("n", "Q", close_all_terminals, vim.tbl_extend("force", opts, { desc = "Terminal: Close All Sessions" }))

      -- Hide terminal with 'Leader + q' in normal mode inside terminal buffer (keeps session running)
      map("n", "<leader>q", hide_current_terminal,
         vim.tbl_extend("force", opts, { desc = "Terminal: Hide Current Session" }))

      -- Shift+Enter -> insert newline in Ink apps (Claude Code, Codex).
      -- Neither relaying Ghostty's raw escape sequence for Shift+Enter nor
      -- sending a bare LF worked - Claude Code doesn't distinguish LF from
      -- CR at all, so a bare LF just submits like plain Enter. But
      -- Alt+Enter already reliably inserts a newline today (ESC + CR, the
      -- classic terminal "meta" prefix convention), so reuse that exact,
      -- already-working byte sequence for Shift+Enter too instead of
      -- inventing yet another format.
      map("t", "\27[27;2;13~", function()
         local job_id = vim.b.terminal_job_id
         if job_id then
            vim.fn.chansend(job_id, "\27\r")
         end
      end, vim.tbl_extend("force", opts, { desc = "Terminal: Send Shift+Enter (newline) to job" }))

      -- Fallback in case Neovim ever does decode it as a named key (e.g. if
      -- Ghostty settings/terminfo change to emit the Kitty CSI-u format).
      map("t", "<S-CR>", function()
         local job_id = vim.b.terminal_job_id
         if job_id then
            vim.fn.chansend(job_id, "\27\r")
         end
      end, vim.tbl_extend("force", opts, { desc = "Terminal: Send Shift+Enter (newline) to job [fallback]" }))

   end,
})

-- Helper to detect if Herdr is active in the terminal's process group
local function is_herdr_active()
   local title = vim.b.term_title or ""
   if string.find(title, "herdr") or string.find(title, "hd") then
      return true
   end
   
   local job_id = vim.b.terminal_job_id
   if not job_id then return false end
   local pid = vim.fn.jobpid(job_id)
   if not pid then return false end
   
   local handle = io.popen("ps -o comm= -g " .. pid)
   if handle then
      local result = handle:read("*a")
      handle:close()
      if result and (string.find(result, "herdr") or string.find(result, "hd")) then
         return true
      end
   end
   return false
end

-- Esc: enter copy mode if in Herdr; exit terminal mode otherwise
map("t", "<Esc>", function()
   if is_herdr_active() then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<A-i>", true, true, true), "t", false)
   else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "n", false)
   end
end, { desc = "Terminal: Context-aware Escape handling" })

-- Alt+Esc (Option+Escape): Force exit terminal mode to normal mode
map("t", "<A-Esc>", [[<C-\><C-n>]], { desc = "Terminal: Force Exit Terminal Mode" })
map("t", "<C-Esc>", "<Esc>", { desc = "Terminal: Send Esc to Terminal" })




-- ==========================================
-- 9. ZEN MODE
-- ==========================================

map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Editor: Toggle Zen Mode" })


-- ==========================================
-- 10. GIT & DIFFVIEW
-- ==========================================

local lazygit = nil
local function toggle_lazygit()
   if not lazygit then
      local Terminal = require("toggleterm.terminal").Terminal
      lazygit = Terminal:new({
         cmd = "lazygit",
         dir = "git_dir",
         direction = "float",
         float_opts = {
            border = "double",
         },
         on_open = function(term)
            vim.cmd("startinsert!")
            -- Prevent standard exit terminal mapping from overriding Esc inside lazygit
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
         end,
      })
   end
   lazygit:toggle()
end
map("n", "<leader>gl", toggle_lazygit, { desc = "Git: Toggle LazyGit Window" })

local lazydocker = nil
map("n", "<leader>dl", function()
   if not lazydocker then
      local Terminal = require("toggleterm.terminal").Terminal
      lazydocker = Terminal:new({
         cmd = "lazydocker",
         dir = "git_dir",
         direction = "float",
         float_opts = {
            border = "double",
         },
         on_open = function(term)
            vim.cmd("startinsert!")
            -- Prevent standard exit terminal mapping from overriding Esc inside lazydocker
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
         end,
      })
   end
   lazydocker:toggle()
end, { desc = "Docker: Toggle LazyDocker Window" })

local open_git_menu
local show_git_commits
local show_file_commits
local compare_branches
local smart_diff_launcher

local function launch_hunk_diff(staged, on_close)
   local cmd = staged and "hunk diff --staged" or "hunk diff"
   local Terminal = require("toggleterm.terminal").Terminal
   local hunk_term = Terminal:new({
      cmd = cmd,
      dir = "git_dir",
      direction = "tab",
      close_on_exit = true,
      on_open = function(term)
         vim.cmd("startinsert!")
         vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
         vim.keymap.set("t", "<S-Esc>", function()
            term.force_quit = true
            term:close()
         end, { buffer = term.bufnr, silent = true })
         vim.keymap.set("t", "Q", function()
            term.force_quit = true
            term:close()
         end, { buffer = term.bufnr, silent = true })
      end,
      on_close = function(term)
         if term.force_quit then return end
         if on_close then
            vim.schedule(on_close)
         end
      end,
   })
   hunk_term:toggle()
end

smart_diff_launcher = function(on_close)
   -- Check for unstaged changes
   vim.fn.system("git diff --quiet")
   local has_unstaged = vim.v.shell_error ~= 0

   -- Check for staged changes
   vim.fn.system("git diff --cached --quiet")
   local has_staged = vim.v.shell_error ~= 0

   if has_unstaged and has_staged then
      -- Both unstaged and staged changes exist, open a Telescope picker
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local diff_options = {
         { "1. View Unstaged Diff (Hunk)", "unstaged" },
         { "2. View Staged Diff (Hunk)", "staged" },
      }

      pickers.new({}, {
         prompt_title = "Select Diff Area",
         finder = finders.new_table({
            results = diff_options,
            entry_maker = function(entry)
               return {
                  value = entry[2],
                  display = entry[1],
                  ordinal = entry[1],
               }
            end,
         }),
         sorter = conf.generic_sorter({}),
         attach_mappings = function(prompt_bufnr, map_cb)
            actions.select_default:replace(function()
               actions.close(prompt_bufnr)
               local selection = action_state.get_selected_entry()
               if not selection then return end
               local choice = selection.value

               vim.schedule(function()
                  if choice == "unstaged" then
                     launch_hunk_diff(false, on_close)
                  elseif choice == "staged" then
                     launch_hunk_diff(true, on_close)
                  end
               end)
            end)

            local function go_back()
               actions.close(prompt_bufnr)
               if on_close then
                  vim.schedule(on_close)
               end
            end
            map_cb("i", "<Esc>", go_back)
            map_cb("n", "<Esc>", go_back)

            local function force_quit()
               actions.close(prompt_bufnr)
            end
            map_cb("i", "<S-Esc>", force_quit)
            map_cb("n", "<S-Esc>", force_quit)
            map_cb("n", "Q", force_quit)

            return true
         end,
      }):find()
   elseif has_unstaged then
      -- Only unstaged changes exist
      launch_hunk_diff(false, on_close)
   elseif has_staged then
      -- Only staged changes exist
      launch_hunk_diff(true, on_close)
   else
      -- No changes found
      vim.notify("Git: No changes found.", vim.log.levels.INFO)
      if on_close then
         vim.schedule(on_close)
      end
   end
end

local function launch_hunk_show(target, file_path, on_close)
   local cmd = "hunk show"
   if target and target ~= "" then
      cmd = cmd .. " " .. target
   end
   if file_path and file_path ~= "" then
      cmd = cmd .. " -- " .. vim.fn.shellescape(file_path)
   end
   local Terminal = require("toggleterm.terminal").Terminal
   local hunk_term = Terminal:new({
      cmd = cmd,
      dir = "git_dir",
      direction = "tab",
      close_on_exit = true,
      on_open = function(term)
         vim.cmd("startinsert!")
         vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
         vim.keymap.set("t", "<S-Esc>", function()
            term.force_quit = true
            term:close()
         end, { buffer = term.bufnr, silent = true })
         vim.keymap.set("t", "Q", function()
            term.force_quit = true
            term:close()
         end, { buffer = term.bufnr, silent = true })
      end,
      on_close = function(term)
         if term.force_quit then return end
         if on_close then
            vim.schedule(on_close)
         end
      end,
   })
   hunk_term:toggle()
end

compare_branches = function(on_close)
   -- Get all local and remote branch names
   local branches = vim.fn.systemlist("git branch -a --format='%(refname:short)'")
   local clean_branches = {}
   for _, branch in ipairs(branches) do
      if branch ~= "" and branch ~= "origin" then
         if not branch:match("/HEAD$") then
            table.insert(clean_branches, branch)
         end
      end
   end

   -- Prioritize origin/main at the top of the list if it exists
   local default_branch = "origin/main"
   local found_idx = nil
   for i, b in ipairs(clean_branches) do
      if b == default_branch then
         found_idx = i
         break
      end
   end
   if found_idx then
      table.remove(clean_branches, found_idx)
      table.insert(clean_branches, 1, default_branch)
   end

   -- Add helper choices
   table.insert(clean_branches, 1, "Enter Custom Ref / Branch...")
   table.insert(clean_branches, 1, "Working Tree (Local Changes)")

   -- Load Telescope dependencies
   local pickers = require("telescope.pickers")
   local finders = require("telescope.finders")
   local conf = require("telescope.config").values
   local actions = require("telescope.actions")
   local action_state = require("telescope.actions.state")

   -- Launch Telescope picker
   pickers.new({}, {
      prompt_title = "Select branch to diff against",
      finder = finders.new_table({
         results = clean_branches,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map_cb)
         actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then return end
            local choice = selection[1]

            local function launch_hunk(target)
               local cmd = "hunk diff"
               if target and target ~= "" then
                  cmd = cmd .. " " .. target
               end
               local Terminal = require("toggleterm.terminal").Terminal
               local hunk_term = Terminal:new({
                  cmd = cmd,
                  dir = "git_dir",
                  direction = "tab",
                  close_on_exit = true,
                  on_open = function(term)
                     vim.cmd("startinsert!")
                     vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
                     vim.keymap.set("t", "<S-Esc>", function()
                        term.force_quit = true
                        term:close()
                     end, { buffer = term.bufnr, silent = true })
                     vim.keymap.set("t", "Q", function()
                        term.force_quit = true
                        term:close()
                     end, { buffer = term.bufnr, silent = true })
                  end,
                  on_close = function(term)
                     if term.force_quit then return end
                     vim.schedule(function()
                        compare_branches(on_close)
                     end)
                  end,
               })
               hunk_term:toggle()
            end

            -- Run after Telescope closes to prevent focus race condition and start in insert mode
            vim.schedule(function()
               if choice == "Working Tree (Local Changes)" then
                  launch_hunk(nil)
               elseif choice == "Enter Custom Ref / Branch..." then
                  vim.ui.input({ prompt = "Enter custom branch/commit ref: " }, function(input_ref)
                     if not input_ref or input_ref == "" then
                        vim.schedule(function()
                           compare_branches(on_close)
                        end)
                        return
                     end
                     launch_hunk(input_ref)
                  end)
               else
                  launch_hunk(choice)
               end
            end)
         end)

         local function go_back()
            actions.close(prompt_bufnr)
            if on_close then
               vim.schedule(on_close)
            end
         end
         map_cb("i", "<Esc>", go_back)
         map_cb("n", "<Esc>", go_back)

         local function force_quit()
            actions.close(prompt_bufnr)
         end
         map_cb("i", "<S-Esc>", force_quit)
         map_cb("n", "<S-Esc>", force_quit)
         map_cb("n", "Q", force_quit)

         return true
      end,
   }):find()
end

-- Open CodeDiff in inline mode
local function open_codediff_inline()
   local ok, config = pcall(require, "codediff.config")
   if ok and config.options and config.options.diff then
      config.options.diff.layout = "inline"
   end
   vim.cmd("CodeDiff")
end

-- Open CodeDiff in side-by-side mode
local function open_codediff_side()
   local ok, config = pcall(require, "codediff.config")
   if ok and config.options and config.options.diff then
      config.options.diff.layout = "side-by-side"
   end
   vim.cmd("CodeDiff")
end


-- Close CodeDiff session / tab
local function close_codediff()
   vim.cmd("tabclose")
end

show_git_commits = function()
   local actions = require("telescope.actions")
   local action_state = require("telescope.actions.state")

   require("telescope.builtin").git_commits({
      attach_mappings = function(commits_prompt_bufnr, commits_map_cb)
         actions.select_default:replace(function()
            actions.close(commits_prompt_bufnr)
            local commits_selection = action_state.get_selected_entry()
            if not commits_selection then return end
            local commit_hash = commits_selection.value
            vim.schedule(function()
               launch_hunk_show(commit_hash, nil, show_git_commits)
            end)
         end)

         local function go_back()
            actions.close(commits_prompt_bufnr)
            vim.schedule(open_git_menu)
         end
         commits_map_cb("i", "<Esc>", go_back)
         commits_map_cb("n", "<Esc>", go_back)

         local function force_quit()
            actions.close(commits_prompt_bufnr)
         end
         commits_map_cb("i", "<S-Esc>", force_quit)
         commits_map_cb("n", "<S-Esc>", force_quit)
         commits_map_cb("n", "Q", force_quit)
         return true
      end,
   })
end

show_file_commits = function(current_file)
   local actions = require("telescope.actions")
   local action_state = require("telescope.actions.state")

   require("telescope.builtin").git_bcommits({
      attach_mappings = function(bcommits_prompt_bufnr, bcommits_map_cb)
         actions.select_default:replace(function()
            actions.close(bcommits_prompt_bufnr)
            local bcommits_selection = action_state.get_selected_entry()
            if not bcommits_selection then return end
            local commit_hash = bcommits_selection.value
            vim.schedule(function()
               launch_hunk_show(commit_hash, current_file, function()
                  show_file_commits(current_file)
               end)
            end)
         end)

         local function go_back()
            actions.close(bcommits_prompt_bufnr)
            vim.schedule(open_git_menu)
         end
         bcommits_map_cb("i", "<Esc>", go_back)
         bcommits_map_cb("n", "<Esc>", go_back)

         local function force_quit()
            actions.close(bcommits_prompt_bufnr)
         end
         bcommits_map_cb("i", "<S-Esc>", force_quit)
         bcommits_map_cb("n", "<S-Esc>", force_quit)
         bcommits_map_cb("n", "Q", force_quit)
         return true
      end,
   })
end

open_git_menu = function()
   local current_file = vim.api.nvim_buf_get_name(0)
   if current_file == "" or vim.bo.buftype ~= "" then
      current_file = nil
   end

   local pickers = require("telescope.pickers")
   local finders = require("telescope.finders")
   local conf = require("telescope.config").values
   local actions = require("telescope.actions")
   local action_state = require("telescope.actions.state")

   local items = {
      { "1. View Current Diff (Hunk)", "hunk_diff" },
      { "2. Compare Branches / Review PR", "compare_branches" },
      { "3. View Git Commits (Telescope)", "tele_commits" },
      { "4. Git History for Current File (Telescope)", "tele_bcommits" },
      { "5. Git Status & Stage (Telescope)", "tele_status" },
      { "6. CodeDiff (Side-by-Side)", "codediff_side" },
      { "7. CodeDiff (Inline)", "codediff_inline" },
      { "8. File History (CodeDiff)", "codediff_history" },
      { "9. Git Branches (Telescope)", "tele_branches" },
      { "10. Git Stashes (Telescope)", "tele_stash" },
      { "11. Open LazyGit", "lazygit" },
      { "12. Open Neogit", "neogit" },
   }

   pickers.new({}, {
      prompt_title = "Git Operations & Diffs",
      finder = finders.new_table({
         results = items,
         entry_maker = function(entry)
            return {
               value = entry[2],
               display = entry[1],
               ordinal = entry[1],
            }
         end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map_cb)
         actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then return end
            local action = selection.value

            vim.schedule(function()
               if action == "hunk_diff" then
                  smart_diff_launcher(open_git_menu)
               elseif action == "compare_branches" then
                  compare_branches(open_git_menu)
               elseif action == "tele_commits" then
                  show_git_commits()
               elseif action == "tele_bcommits" then
                  show_file_commits(current_file)
               elseif action == "tele_status" then
                  require("telescope.builtin").git_status({
                     attach_mappings = function(status_prompt_bufnr, status_map_cb)
                        local function go_back()
                           actions.close(status_prompt_bufnr)
                           vim.schedule(open_git_menu)
                        end
                        status_map_cb("i", "<Esc>", go_back)
                        status_map_cb("n", "<Esc>", go_back)

                        local function force_quit()
                           actions.close(status_prompt_bufnr)
                        end
                        status_map_cb("i", "<S-Esc>", force_quit)
                        status_map_cb("n", "<S-Esc>", force_quit)
                        status_map_cb("n", "Q", force_quit)
                        return true
                     end,
                  })
               elseif action == "codediff_side" then
                  open_codediff_side()
               elseif action == "codediff_inline" then
                  open_codediff_inline()
               elseif action == "codediff_history" then
                  vim.cmd("CodeDiff history")
               elseif action == "tele_branches" then
                  require("telescope.builtin").git_branches({
                     attach_mappings = function(branches_prompt_bufnr, branches_map_cb)
                        local function go_back()
                           actions.close(branches_prompt_bufnr)
                           vim.schedule(open_git_menu)
                        end
                        branches_map_cb("i", "<Esc>", go_back)
                        branches_map_cb("n", "<Esc>", go_back)

                        local function force_quit()
                           actions.close(branches_prompt_bufnr)
                        end
                        branches_map_cb("i", "<S-Esc>", force_quit)
                        branches_map_cb("n", "<S-Esc>", force_quit)
                        branches_map_cb("n", "Q", force_quit)
                        return true
                     end,
                  })
               elseif action == "tele_stash" then
                  require("telescope.builtin").git_stash({
                     attach_mappings = function(stash_prompt_bufnr, stash_map_cb)
                        local function go_back()
                           actions.close(stash_prompt_bufnr)
                           vim.schedule(open_git_menu)
                        end
                        stash_map_cb("i", "<Esc>", go_back)
                        stash_map_cb("n", "<Esc>", go_back)

                        local function force_quit()
                           actions.close(stash_prompt_bufnr)
                        end
                        stash_map_cb("i", "<S-Esc>", force_quit)
                        stash_map_cb("n", "<S-Esc>", force_quit)
                        stash_map_cb("n", "Q", force_quit)
                        return true
                     end,
                  })
               elseif action == "lazygit" then
                  toggle_lazygit()
               elseif action == "neogit" then
                  vim.cmd("Neogit")
               end
            end)
         end)

         local function force_quit()
            actions.close(prompt_bufnr)
         end
         map_cb("i", "<S-Esc>", force_quit)
         map_cb("n", "<S-Esc>", force_quit)
         map_cb("n", "Q", force_quit)
         return true
      end,
   }):find()
end

map("n", "<leader>gj", smart_diff_launcher, { desc = "Git: Open Hunk Diff Viewer (Tab)" })
map("n", "<leader>gh", smart_diff_launcher, { desc = "Git: Open Hunk Diff Viewer (Tab)" })
map("n", "<leader>gb", compare_branches, { desc = "Git: Compare Branches / Review PR" })

map("n", "<leader>gg", open_git_menu, { desc = "Git: Operations & Diffs Menu" })
map("n", "<leader>gn", "<cmd>Neogit<CR>", { desc = "Git: Toggle Neogit Status" })

map("n", "<leader>gd", open_codediff_inline, { desc = "Git: CodeDiff Open (Inline/Single Window)" })
map("n", "<leader>gr", open_codediff_side, { desc = "Git: CodeDiff Open (Side-by-Side)" })
map("n", "<leader>gD", close_codediff, { desc = "Git: CodeDiff Close Session" })
map("n", "<leader>gx", "<cmd>CodeDiff history<CR>", { desc = "Git: CodeDiff File History" })
map("x", "<leader>gx", ":CodeDiff history<CR>", { desc = "Git: CodeDiff File History" })

-- Map 'l' and 'o' to open files/toggle folders in CodeDiff explorer/history sidebars
vim.api.nvim_create_autocmd("FileType", {
   desc = "Configure keymaps for CodeDiff explorer and history sidebars",
   pattern = { "codediff-explorer", "codediff-history" },
   callback = function(event)
      vim.keymap.set("n", "l", "<CR>",
         { buffer = event.buf, remap = true, silent = true, desc = "CodeDiff: Open selected file / Toggle folder" })
      vim.keymap.set("n", "o", "<CR>",
         { buffer = event.buf, remap = true, silent = true, desc = "CodeDiff: Open selected file / Toggle folder" })

      if event.match == "codediff-explorer" then
         -- 's' to stage single file
         vim.keymap.set("n", "s", function()
            local ok_lifecycle, lifecycle = pcall(require, "codediff.ui.lifecycle")
            if not ok_lifecycle then return end
            local tabpage = vim.api.nvim_get_current_tabpage()
            local explorer = lifecycle.get_explorer(tabpage)
            if not explorer or not explorer.tree then return end
            local node = explorer.tree:get_node()
            if not node or not node.data or node.data.type == "group" then return end

            local group = node.data.group
            if group == "unstaged" or group == "conflicts" then
               local ok_actions, actions = pcall(require, "codediff.ui.explorer.actions")
               if ok_actions then
                  actions.toggle_stage_entry(explorer, explorer.tree)
               end
            end
         end, { buffer = event.buf, silent = true, desc = "CodeDiff: Stage Selected File/Directory" })

         -- 'u' to unstage single file
         vim.keymap.set("n", "u", function()
            local ok_lifecycle, lifecycle = pcall(require, "codediff.ui.lifecycle")
            if not ok_lifecycle then return end
            local tabpage = vim.api.nvim_get_current_tabpage()
            local explorer = lifecycle.get_explorer(tabpage)
            if not explorer or not explorer.tree then return end
            local node = explorer.tree:get_node()
            if not node or not node.data or node.data.type == "group" then return end

            local group = node.data.group
            if group == "staged" then
               local ok_actions, actions = pcall(require, "codediff.ui.explorer.actions")
               if ok_actions then
                  actions.toggle_stage_entry(explorer, explorer.tree)
               end
            end
         end, { buffer = event.buf, silent = true, desc = "CodeDiff: Unstage Selected File/Directory" })
      end
   end,
})




-- ==========================================
-- 11. LSP BUILT-IN KEYMAPS (Attached per buffer)
-- ==========================================

vim.api.nvim_create_autocmd('LspAttach', {
   desc = 'LSP actions and overrides',
   callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if not client then
         return
      end

      if client.name:match("^obsidian") then
         return
      end

      -- Go to definition (standard IDE behavior)
      if client.supports_method('textDocument/definition') then
         vim.keymap.set('n', 'gd', vim.lsp.buf.definition,
            { buffer = event.buf, silent = true, desc = "LSP: Go to Definition" })
         -- Skip mapping 'gf' to LSP definition in markdown files to allow obsidian.nvim/native follow-link to work
         if vim.bo[event.buf].filetype ~= "markdown" then
            vim.keymap.set('n', 'gf', vim.lsp.buf.definition,
               { buffer = event.buf, silent = true, desc = "LSP: Go to File under Cursor" })
         end
      end

      if client.supports_method('textDocument/declaration') then
         vim.keymap.set('n', 'gD', vim.lsp.buf.declaration,
            { buffer = event.buf, silent = true, desc = "LSP: Go to Declaration" })
      end
      if client.supports_method('textDocument/implementation') then
         vim.keymap.set('n', 'gi', vim.lsp.buf.implementation,
            { buffer = event.buf, silent = true, desc = "LSP: Go to Implementation" })
      end
      if client.supports_method('textDocument/typeDefinition') then
         vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition,
            { buffer = event.buf, silent = true, desc = "LSP: Go to Type Definition" })
      end
      if client.supports_method('textDocument/references') then
         vim.keymap.set('n', 'gr', vim.lsp.buf.references,
            { buffer = event.buf, silent = true, desc = "LSP: Go to References" })
      end
      if client.supports_method('textDocument/hover') then
         vim.keymap.set('n', 'gh', vim.lsp.buf.hover,
            { buffer = event.buf, silent = true, desc = "LSP: Show Hover Documentation" })
      end
      if client.supports_method('textDocument/rename') then
         vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,
            { buffer = event.buf, silent = true, desc = "LSP: Rename Symbol" })
      end
      if client.supports_method('textDocument/codeAction') then
         vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action,
            { buffer = event.buf, silent = true, desc = "LSP: Execute Code Action" })
      end
   end,
})


-- ==========================================
-- 12. DISABLE ALT/OPTION MODIFIERS IN INSERT MODE
-- ==========================================

-- Disable all Alt + lowercase letter combinations in insert mode to prevent dropping to normal mode
local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
   "v", "w", "x", "y", "z" }
for _, char in ipairs(letters) do
   map("i", "<A-" .. char .. ">", "<Nop>", { desc = "Disable Alt modifier in insert mode" })
end



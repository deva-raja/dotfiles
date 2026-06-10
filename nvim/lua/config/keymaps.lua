-- Keymaps configuration file
-- Organized by category: Core/General, Window Navigation, Splits, Bufferline, Search/Telescope, LSP, Harpoon, Terminal, Zen Mode, etc.

local map = vim.keymap.set
local opts = { silent = true }

-- ==========================================
-- 1. CORE / GENERAL MAPPINGS
-- ==========================================

-- Save file (mimicking VS Code Ctrl+S and Cmd+S)
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save file" })
map("x", "<C-s>", "<cmd>w<CR>gv", { desc = "Save file" })

map("n", "<D-s>", "<cmd>w<CR>", { desc = "Save file" })
map("i", "<D-s>", "<Esc>:w<CR>a", { desc = "Save file" })
map("x", "<D-s>", "<cmd>w<CR>gv", { desc = "Save file" })

-- Toggle comment (mimicking VS Code Cmd+/)
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle comment line" })
map("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment line" })
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment line" })

map("x", "<D-/>", "gc", { remap = true, desc = "Toggle comment selection" })
map("x", "<C-/>", "gc", { remap = true, desc = "Toggle comment selection" })
map("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment selection" })

map("i", "<D-/>", "<Esc>gcca", { remap = true, desc = "Toggle comment line" })
map("i", "<C-/>", "<Esc>gcca", { remap = true, desc = "Toggle comment line" })
map("i", "<C-_>", "<Esc>gcca", { remap = true, desc = "Toggle comment line" })

-- Faster vertical movement (J / K moving 5 lines instead of 1, as configured in VS Code)
map({ "n", "x" }, "J", "5j", { desc = "Move down 5 lines" })
map({ "n", "x" }, "K", "5k", { desc = "Move up 5 lines" })

-- Insert line below and return to normal mode (VS Code insertLineAfter)
map("n", "<leader>p", "o<Esc>", { desc = "Insert line below" })

-- Muscle memory helpers from your VS Code Vim settings:
-- gn -> * (search word under cursor)
-- gj -> ^ (start of line)
-- gl -> % (matching bracket/parentheses)
map({ "n", "x", "o" }, "gn", "*", { desc = "Search word under cursor" })
map({ "n", "x", "o" }, "gj", "^", { desc = "Go to first non-blank character" })
map({ "n", "x", "o" }, "gl", "%", { desc = "Go to matching bracket" })

-- Invert default jump list navigation:
-- Ctrl+O jumps forward (inbuilt is Ctrl+I)
-- Ctrl+I jumps backward (inbuilt is Ctrl+O)
map("n", "<C-o>", "<C-i>", { desc = "Jump forward in history" })
map("n", "<C-i>", "<C-o>", { desc = "Jump backward in history" })

-- Jump back in jump list (<leader>a -> Ctrl+I which is now backward)
map("n", "<leader>a", "<C-i>", { desc = "Jump back in history" })

-- Search command mapping (<leader>c -> /)
map("n", "<leader>c", "/", { desc = "Search forward" })

-- Clear search highlights on pressing Escape in normal mode
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlights" })

-- Close Neovim completely (Quit all)
map("n", "<leader><Esc>", "<cmd>qa<CR>", { silent = true, desc = "Quit Neovim" })

-- Indent/outdent in visual mode keeping selection active (Tab / Shift-Tab)
map("v", "<Tab>", ">gv", { desc = "Indent selection" })
map("v", "<S-Tab>", "<gv", { desc = "Outdent selection" })

-- Keep cursor centered when jumping to the bottom of the file
map({ "n", "x" }, "G", "Gzz", { desc = "Go to bottom and center view" })

-- Copy selection/line to clipboard (Cmd + C)
map("n", "<D-c>", '"+yy', { desc = "Copy line to clipboard" })
map("x", "<D-c>", '"+y', { desc = "Copy selection to clipboard" })

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
end, { desc = "Copy relative path with @ for agent CLI" })

map("n", "<leader>yP", function()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("No file active", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Copied absolute path: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute path" })

-- Undo & Redo (Cmd + Z & Cmd + Y)
map("n", "<D-z>", "u", { desc = "Undo" })
map("i", "<D-z>", "<C-o>u", { desc = "Undo" })
map("n", "<D-y>", "<C-r>", { desc = "Redo" })
map("i", "<D-y>", "<C-o><C-r>", { desc = "Redo" })

-- Alt/Option + Backspace in insert mode to delete word before cursor (Mac bindings)
map("i", "<A-BS>", "<C-w>", { desc = "Delete word before cursor" })
map("i", "<M-BS>", "<C-w>", { desc = "Delete word before cursor" })
map("i", "<A-Backspace>", "<C-w>", { desc = "Delete word before cursor" })
map("i", "<M-Backspace>", "<C-w>", { desc = "Delete word before cursor" })
map("i", "<Esc><BS>", "<C-w>", { desc = "Delete word before cursor" })
map("i", "<Esc><Backspace>", "<C-w>", { desc = "Delete word before cursor" })

-- Toggle Neo-tree sidebar with Command + \ (mimicking VS Code sidebar toggle)
map({ "n", "i", "x" }, "<D-\\>", "<cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree sidebar" })

-- Toggle comments with Command + / (mimicking VS Code)
map("n", "<D-/>", "gcc", { remap = true, desc = "Toggle comment" })
map("x", "<D-/>", "gc", { remap = true, desc = "Toggle comment" })
map("i", "<D-/>", "<C-o>gcc", { remap = true, desc = "Toggle comment" })


-- ==========================================
-- 2. WINDOW NAVIGATION
-- ==========================================

-- Horizontal movement mapping (<leader>h and <leader>l)
map("n", "<leader>h", "<C-w>h", { desc = "Navigate to left window" })
map("n", "<leader>l", "<C-w>l", { desc = "Navigate to right window" })

-- Vertical window movement mappings (<leader>j and <leader>k)
map("n", "<leader>k", "<C-w>k", { desc = "Navigate to top window" })
map("n", "<leader>j", "<C-w>j", { desc = "Navigate to bottom window" })


-- ==========================================
-- 3. SPLIT MANAGEMENT
-- ==========================================

map("n", "<leader>gv", "<cmd>vsplit<CR>", { desc = "Split window vertically" })
map("n", "<leader>gh", "<cmd>split<CR>", { desc = "Split window horizontally" })


-- ==========================================
-- 4. BUFFER NAVIGATION (Bufferline)
-- ==========================================

-- Close buffers
map("n", "<leader>w", "<cmd>bdelete<CR>", { desc = "Close active buffer" })
map("n", "<leader>gc", "<cmd>%bd|e#|bd#<CR>", { desc = "Close other buffers" })



-- ==========================================
-- 5. SEARCH & NAVIGATION (Telescope)
-- ==========================================

map("n", "<leader>i", function()
  local utils = require("telescope.utils")
  local _, ret, _ = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
  if ret == 0 then
    require("telescope.builtin").git_files()
  else
    require("telescope.builtin").find_files()
  end
end, { desc = "Find files (Git / Workspace)" })
map("n", "<leader>s", "<cmd>Telescope live_grep<CR>", { desc = "Global search (live grep)" })
map("n", "<leader>;", "<cmd>Telescope commands<CR>", { desc = "Command palette" })
map("n", "<leader>n", "<cmd>Telescope buffers<CR>", { desc = "Find open buffers" })
map("n", "<leader>?", "<cmd>Telescope keymaps<CR>", { desc = "Search keymaps" })
map("n", "<leader>/", function() require("spectre").toggle() end, { desc = "Toggle Spectre (Search & Replace)" })
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

map("n", "<leader>e", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Go to symbol in file" })
map("n", "<leader>u", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Go to symbol in workspace" })
map("n", "<leader>o", function() require("conform").format({ async = true, lsp_fallback = true }) end, { desc = "Format document" })


-- ==========================================
-- 7. BOOKMARKS & MINIMAP
-- ==========================================

-- Bookmarks (b for Bookmarks)
map("n", "<leader>ba", function() require("bookmarks").add_bookmarks() end, { desc = "Add bookmark at line" })
map("n", "<leader>bt", function() require("bookmarks").toggle_bookmarks() end, { desc = "Toggle bookmarks list" })

-- Minimap (m for Minimap)
map("n", "<leader>mm", function() require("mini.map").toggle() end, { desc = "Toggle Minimap" })
map("n", "<leader>mf", function() require("mini.map").toggle_focus() end, { desc = "Focus Minimap" })

-- Markdown rendering (m for Markdown, r for Render)
local is_minimal = vim.fn.exists('$SSH_CONNECTION') == 1 or vim.fn.filereadable(vim.fn.stdpath('config') .. '/.minimal') == 1
if not is_minimal then
  map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle Markdown rendering" })
end


-- ==========================================
-- 8. TERMINAL (ToggleTerm)
-- ==========================================

-- Toggle terminal with <leader>tt or Ctrl+` (same as VS Code)
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })
map({ "n", "t" }, "<C-`>", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })

-- Toggle terminal with Command + j (mimicking VS Code Cmd+J panel toggle)
map({ "n", "i", "t" }, "<D-j>", "<cmd>ToggleTerm<CR>", { desc = "Toggle Terminal" })

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
map({ "n", "i", "v" }, "<D-m>", focus_terminal, { desc = "Focus terminal from editor" })

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

-- Helper function to close the current terminal (fully destroy/shutdown session)
local function close_current_terminal()
  local term_module = require("toggleterm.terminal")
  local _, term = term_module.identify()
  if term then
    term:shutdown()
  else
    vim.cmd("bdelete!")
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
    map({ "t", "n" }, "<D-n>", spawn_new_terminal, vim.tbl_extend("force", opts, { desc = "New terminal session" }))
    map({ "t", "n" }, "<C-n>", spawn_new_terminal, vim.tbl_extend("force", opts, { desc = "New terminal session" }))

    -- Cycle previous/next: Command + 8 and Command + 9
    map({ "t", "n" }, "<D-8>", function() cycle_terminals("prev") end, vim.tbl_extend("force", opts, { desc = "Previous terminal session" }))
    map({ "t", "n" }, "<D-9>", function() cycle_terminals("next") end, vim.tbl_extend("force", opts, { desc = "Next terminal session" }))

    -- Select picker: Command + ;
    map({ "t", "n" }, "<D-;>", select_terminal_custom, vim.tbl_extend("force", opts, { desc = "Select terminal session" }))

    -- Focus editor back from terminal with Command + m
    map({ "t", "n" }, "<D-m>", [[<C-\><C-n><C-w>p]], vim.tbl_extend("force", opts, { desc = "Focus editor from terminal" }))

    -- Close terminal with 'q' in normal mode inside terminal buffer (destroys process)
    map("n", "q", close_current_terminal, vim.tbl_extend("force", opts, { desc = "Close terminal (destroy)" }))

    -- Hide terminal with 'Leader + q' in normal mode inside terminal buffer (keeps session running)
    map("n", "<leader>q", hide_current_terminal, vim.tbl_extend("force", opts, { desc = "Hide terminal (keep running)" }))
  end,
})

-- Esc in terminal mode to return to normal mode inside ToggleTerm (global fallback/helper)
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-Esc>", "<Esc>", { desc = "Send Esc to terminal" })




-- ==========================================
-- 9. ZEN MODE
-- ==========================================

map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle Zen Mode" })


-- ==========================================
-- 10. GIT & DIFFVIEW
-- ==========================================

local lazygit = nil
map("n", "<leader>gl", function()
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
end, { desc = "Toggle LazyGit" })

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
end, { desc = "Toggle LazyDocker" })

map("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Open Neogit" })

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

map("n", "<leader>gd", open_codediff_inline, { desc = "Git CodeDiff Open (Inline/Single Window)" })
map("n", "<leader>gr", open_codediff_side, { desc = "Git CodeDiff Open (Side-by-Side)" })
map("n", "<leader>gD", close_codediff, { desc = "Git CodeDiff Close" })
map("n", "<leader>ghs", "<cmd>CodeDiff history<CR>", { desc = "Git File History" })
map("x", "<leader>ghs", ":CodeDiff history<CR>", { desc = "Git File History" })

-- Map 'l' and 'o' to open files/toggle folders in CodeDiff explorer/history sidebars
vim.api.nvim_create_autocmd("FileType", {
  desc = "Configure keymaps for CodeDiff explorer and history sidebars",
  pattern = { "codediff-explorer", "codediff-history" },
  callback = function(event)
    vim.keymap.set("n", "l", "<CR>", { buffer = event.buf, remap = true, silent = true, desc = "Open selected file / Toggle folder" })
    vim.keymap.set("n", "o", "<CR>", { buffer = event.buf, remap = true, silent = true, desc = "Open selected file / Toggle folder" })

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
      end, { buffer = event.buf, silent = true, desc = "Stage selected file/directory" })

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
      end, { buffer = event.buf, silent = true, desc = "Unstage selected file/directory" })
    end
  end,
})




-- ==========================================
-- 11. LSP BUILT-IN KEYMAPS (Attached per buffer)
-- ==========================================

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions and overrides',
  callback = function(event)
    local opts = { buffer = event.buf, silent = true }

    -- Go to definition (standard IDE behavior)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = event.buf, silent = true, desc = "Go to definition" })
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = event.buf, silent = true, desc = "Go to declaration" })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = event.buf, silent = true, desc = "Go to implementation" })
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = event.buf, silent = true, desc = "Go to type definition" })
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = event.buf, silent = true, desc = "Go to references" })
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { buffer = event.buf, silent = true, desc = "Hover documentation" })
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = event.buf, silent = true, desc = "Rename symbol" })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, silent = true, desc = "Code action" })

    -- Map 'gf' to use LSP definition (resolves TS path aliases like @/ and extensionless imports!)
    vim.keymap.set('n', 'gf', vim.lsp.buf.definition, { buffer = event.buf, silent = true, desc = "Go to file (via LSP)" })
  end,
})


-- ==========================================
-- 12. DISABLE ALT/OPTION MODIFIERS IN INSERT MODE
-- ==========================================

-- Disable all Alt + lowercase letter combinations in insert mode to prevent dropping to normal mode
local letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" }
for _, char in ipairs(letters) do
  map("i", "<A-" .. char .. ">", "<Nop>", { desc = "Disable Alt modifier in insert mode" })
end



-- Options configuration file
-- Core settings that modify Neovim's default behavior

local opt = vim.opt

-- Disable netrw to prevent conflicts with Neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Line numbering
opt.number = true
opt.relativenumber = true

-- Clipboard integration: Share clipboard with OS system clipboard
opt.clipboard = "unnamedplus"

-- Tabs & Indentation (Configuring smart defaults, matching Prettier preferences)
opt.tabstop = 3        -- Number of spaces that a Tab in the file counts for
opt.shiftwidth = 3     -- Number of spaces to use for each step of (auto)indent
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Insert indents automatically

-- Search settings (matching sneak/easymotion ignorecase & smartcase)
opt.ignorecase = true  -- Ignore case in search patterns
opt.smartcase = true   -- Override ignorecase if search contains capitals
opt.hlsearch = true    -- Highlight all matches of previous search pattern
opt.incsearch = true   -- Show search results while typing
opt.gdefault = true    -- Substitute globally by default (matching VS Code vim.gdefault)

-- Look and Feel
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.signcolumn = "yes"   -- Always show the sign column (prevents shift when git/lsp signs appear)
opt.wrap = false         -- Do not wrap lines
opt.scrolloff = 8        -- Keep at least 8 lines above/below cursor when scrolling
opt.sidescrolloff = 8    -- Keep at least 8 columns to the left/right of cursor

-- Timing/Delays
opt.updatetime = 250     -- Faster completion / git signs refresh (default is 4000ms)
opt.timeoutlen = 300     -- Time in ms to wait for a mapped sequence to complete

-- Disable terminal flow control (prevents Ctrl+S from freezing terminal input)
vim.cmd('silent !stty -ixon')

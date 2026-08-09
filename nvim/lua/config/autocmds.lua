-- Markdown reading view: no gutter, calmer colorscheme.
local augroup = vim.api.nvim_create_augroup("MarkdownReadingView", { clear = true })

-- Hide line numbers/signcolumn, wrap prose at word boundaries (the rest of
-- the editor keeps 'wrap = false' for code; this is markdown-only).
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "markdown",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    -- conceallevel=2 lets render-markdown.nvim actually hide raw "#"/"**"
    -- markup; concealcursor="" (not "nc") means the cursor's own line stays
    -- revealed for editing, matching Obsidian's Live Preview behavior.
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""
  end,
})

-- Markdown heading/quote/link improvements applied on top of rose-pine-moon.
-- Registered on ColorScheme so they survive theme reloads.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  pattern = "rose-pine-moon",
  callback = function()
    for level = 1, 6 do
      vim.api.nvim_set_hl(0, "@markup.heading." .. level .. ".markdown", { link = "Function", bold = true })
    end
    vim.api.nvim_set_hl(0, "@markup.heading", { link = "Function", bold = true })

    vim.api.nvim_set_hl(0, "@markup.quote", { bg = "#2a273f" }) -- rose-pine surface
    vim.api.nvim_set_hl(0, "@markup.quote.markdown", { bg = "#2a273f" })

    vim.api.nvim_set_hl(0, "@markup.link.url", { fg = "#6e6a86", underline = true }) -- rose-pine muted
    vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { fg = "#6e6a86" })
  end,
})

-- Automatically reload files changed on disk (non-destructive)
local autoreload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})


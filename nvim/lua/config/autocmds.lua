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

-- Switch to a calmer reading colorscheme while focused on a markdown
-- buffer; restore on leaving. Gated on buftype == "" so transient overlays
-- (Telescope's prompt buffer, terminal, quickfix, command-line) never
-- trigger it. base_colorscheme is captured once at startup rather than
-- re-captured dynamically, to keep this simple and avoid ever landing on a
-- stale value.
local READING_COLORSCHEME = "kanagawa-dragon"
local base_colorscheme = vim.g.colors_name or "rose-pine-moon"

local function set_colorscheme(name)
  if name and vim.g.colors_name ~= name then
    pcall(vim.cmd.colorscheme, name)
  end
end

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup,
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then return end
    if vim.bo[ev.buf].filetype == "markdown" then
      set_colorscheme(READING_COLORSCHEME)
    else
      set_colorscheme(base_colorscheme)
    end
  end,
})

-- kanagawa-dragon is only ever active inside markdown buffers (the switch
-- above), so these highlight tweaks can never bleed into code-file editing.
-- Registered on ColorScheme (same pattern lua/plugins/mini-nvim.lua uses for
-- its own highlight refresh) so they get reapplied every time the scheme
-- (re)loads, since :colorscheme re-sources the whole scheme each time.
vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  pattern = "kanagawa-dragon",
  callback = function()
    -- Bold headings: kanagawa-dragon only defines the generic @markup.heading,
    -- linked to a non-bold "Function" color. Keep the color, just add weight.
    for level = 1, 6 do
      vim.api.nvim_set_hl(0, "@markup.heading." .. level .. ".markdown", { link = "Function", bold = true })
    end
    vim.api.nvim_set_hl(0, "@markup.heading", { link = "Function", bold = true })

    -- Subtle background panel behind blockquote body text (Obsidian/Apex-style),
    -- using kanagawa-dragon's own slightly-lighter-than-background palette tone.
    vim.api.nvim_set_hl(0, "@markup.quote", { bg = "#282727" }) -- dragonBlack4
    vim.api.nvim_set_hl(0, "@markup.quote.markdown", { bg = "#282727" })

    -- Mute links: replace the undercurl (spell-check-error style) with a
    -- plain clean underline in a quiet gray, matching Apex's understated links.
    vim.api.nvim_set_hl(0, "@markup.link.url", { fg = "#7a8382", underline = true }) -- dragonGray3
    vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { fg = "#7a8382" })
  end,
})

-- Hide mini.map while in a markdown buffer; restore on leaving. Also fires
-- on BufWinEnter: mini.map (lua/plugins/mini-nvim.lua) auto-opens itself on
-- {"VimEnter", "BufWinEnter"}, via a callback that wraps its minimap.open()
-- in vim.schedule() — meaning it runs on the next event loop tick, not
-- synchronously during the event. A plain synchronous close() here, however
-- it's ordered, still gets undone afterward. Wrapping our own open/close in
-- vim.schedule() too puts it in the same deferred queue; since mini.map's
-- autocmd is registered first (mini-nvim.lua loads before this file), its
-- open() is scheduled first, ours runs after it in the queue, giving us the
-- actual last word.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = augroup,
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then return end
    local is_md = vim.bo[ev.buf].filetype == "markdown"

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then return end
      if is_md then
        pcall(function() require("mini.map").close() end)
      else
        pcall(function() require("mini.map").open() end)
      end
    end)
  end,
})

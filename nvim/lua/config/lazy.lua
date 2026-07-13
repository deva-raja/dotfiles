-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Automatically sync (install/update) plugins, throttled to once a day
local function lazy_auto_sync()
  local stamp_file = vim.fn.stdpath("data") .. "/lazy-sync-stamp"
  local one_day = 24 * 60 * 60
  local now = os.time()
  local last = 0

  local f = io.open(stamp_file, "r")
  if f then
    last = tonumber(f:read("*a")) or 0
    f:close()
  end

  if now - last < one_day then
    return
  end

  require("lazy").sync({ show = false })

  local wf = io.open(stamp_file, "w")
  if wf then
    wf:write(tostring(now))
    wf:close()
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = lazy_auto_sync,
})

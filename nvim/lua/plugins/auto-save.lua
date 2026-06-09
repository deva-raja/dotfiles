return {
  {
    "okuuva/auto-save.nvim",
    cmd = "ASToggle",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      enabled = true,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost" },
        defer_save = { "InsertLeave", "TextChanged" },
      },
      debounce_delay = 1000,
      condition = function(buf)
        local filetype = vim.bo[buf].filetype
        if vim.tbl_contains({ "gitcommit", "gitrebase", "NeogitStatus", "codediff-explorer", "TelescopePrompt" }, filetype) then
          return false
        end
        return true
      end,
      write_all_buffers = false,
    }
  }
}

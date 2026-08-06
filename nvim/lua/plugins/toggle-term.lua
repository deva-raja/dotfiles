return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
      -- Customize the default sizes
      size = function(term)
        if term.direction == "horizontal" then
          -- Default is 20. 10% increase is 22 lines.
          return 22
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      -- Patch Terminal:_display_name to prevent crash when name is nil
      local Terminal = require("toggleterm.terminal").Terminal
      Terminal._display_name = function(self)
        if self.display_name then
          return self.display_name
        end
        if self.name then
          local parts = vim.split(self.name, ";")
          if parts and parts[1] then
            return parts[1]
          end
        end
        return "Terminal " .. tostring(self.id)
      end
    end
  }
}


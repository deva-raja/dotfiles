return {
  {
    "mistweaverco/kulala.nvim",
    event = { "SessionLoadPost", "VimLeavePre" },
    ft = { "http", "rest", "javascript", "lua" },
    keys = {
      { "<leader>rr", function() require("kulala").run() end, desc = "Kulala: Send Request (HTTP/REST)" },
      { "<leader>ro", function() require("kulala").open() end, desc = "Kulala: Open Response Window" },
      { "<leader>rp", function() require("kulala").replay() end, desc = "Kulala: Replay Last Request" },
      { "<leader>rn", function() require("kulala").jump_next() end, desc = "Kulala: Jump to Next Request" },
      { "<leader>rb", function() require("kulala").jump_prev() end, desc = "Kulala: Jump to Previous Request" },
    },
    init = function()
      vim.api.nvim_create_user_command("Kulala", function(opts)
        local subcommand = opts.fargs[1]
        local kulala = require("kulala")
        if subcommand == "run" then
          kulala.run()
        elseif subcommand == "run_all" then
          kulala.run_all()
        elseif subcommand == "scratch" or subcommand == "scratchpad" then
          kulala.scratchpad()
        elseif subcommand == "replay" then
          kulala.replay()
        elseif subcommand == "close" then
          kulala.close()
        elseif subcommand == "copy" then
          kulala.copy()
        elseif subcommand == "from_curl" then
          kulala.from_curl()
        else
          -- Default to run if no subcommand is provided
          kulala.run()
        end
      end, {
        nargs = "?",
        complete = function(ArgLead, CmdLine, CursorPos)
          local subcommands = { "run", "run_all", "scratch", "scratchpad", "replay", "close", "copy", "from_curl" }
          local matches = {}
          for _, sub in ipairs(subcommands) do
            if sub:sub(1, #ArgLead) == ArgLead then
              table.insert(matches, sub)
            end
          end
          return matches
        end,
      })
    end,
    opts = {},
  },
}

-- ==============================================================================
-- Yazi Initialization Script (init.lua)
-- ==============================================================================

-- Apply sorting rules based on path
local function apply_sorting_rules(cwd)
  if not cwd then return end
  if cwd:ends_with("Downloads") or cwd:ends_with("downloads") then
    ya.emit("sort", { "btime", reverse = true, dir_first = false })
  else
    ya.emit("sort", { "alphabetical", reverse = false, dir_first = true })
  end
end

-- Folder-specific rules (e.g., sort Downloads by birth time reverse)
local function setup_folder_rules()
  -- 1. Subscribe to directory changes (covers normal navigation within any tab)
  ps.sub("cd", function()
    local cwd = cx.active.current.cwd
    apply_sorting_rules(cwd)
  end)

  -- 2. Subscribe to tab state updates (covers switching tabs, tab creation, and tab focus changes)
  ps.sub("tab", function()
    local cwd = cx.active.current.cwd
    apply_sorting_rules(cwd)
  end)
end

-- Create a second tab pointing to the original working directory if YAZI_2ND_TAB is set
local function setup_startup_tabs()
  local second_tab = os.getenv("YAZI_2ND_TAB")
  if second_tab and second_tab ~= "" then
    ya.emit("tab_create", { second_tab })
  end
end

-- Run configuration functions
setup_folder_rules()
setup_startup_tabs()

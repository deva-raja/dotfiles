return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false, -- load eagerly, not on FileType — avoids the lazy-loading
                  -- race that previously broke automatic markdown behavior
                  -- on the very first file opened at startup
  },
}

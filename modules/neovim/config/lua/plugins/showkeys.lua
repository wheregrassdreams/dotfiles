return {
  "siduck/showkeys",
  cmd = "ShowkeysToggle",
  opts = {
    timeout = 1,
    maxkeys = 5,
    -- more opts
  },
  keys = {
    {"<Leader><Leader>k", "<cmd>ShowkeysToggle<CR>", desc = "ShowKeys Toggle"}
  }
}

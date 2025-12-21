-- 生成漂亮的代码截图

local save_path = "~/Pictures"

---@type NvPluginSpec
return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader><leader>c", "<cmd>CodeSnap<cr>", mode = "x", desc = "Code Snapshot into Clipboard" },
    { "<leader><leader>s", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save Code Snapshot in " ..  save_path },
  },
  opts = {
    save_path = save_path,
    has_breadcrumbs = true,
    ---@type "bamboo"|"sea"|"peach"|"grape"|"dusk"|"summer"
    bg_theme = "dusk",
  },
}

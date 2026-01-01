-- return {
--   "mistricky/codesnap.nvim",
--   event = { "LazyFile", "VeryLazy" }, -- 需要在选择前加载，不然第一次选择后无法截图
--   build = "make",
--   keys = {
--     { "<leader>@c", "<cmd>CodeSnap<cr>", mode = { "x" }, desc = "Save selected code snapshot into clipboard" },
--     { "<leader>@s", "<cmd>CodeSnapSave<cr>", mode = { "x" }, desc = "Save selected code snapshot in ~/Pictures" },
--   },
--
--   opts = {
--     -- save_path = "~/Pictures",
--     save_path = "~/Downloads/", -- 个人习惯改为下载目录
--     has_breadcrumbs = true,
--     bg_theme = "bamboo",
--
--     bg_padding = 0, -- 隐藏额外的背景
--   },
-- }

return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader>@c", "<cmd>'<,'>CodeSnap<cr>", mode = { "x" }, desc = "Save selected code snapshot into clipboard" },
    { "<leader>@s", "<cmd>'<,'>CodeSnapSave<cr>", mode = { "x" }, desc = "Save selected code snapshot in ~/Pictures" },
    -- 修正后的背景切换快捷键
    {
      "<leader>@b",
      function()
        _G.toggle_codesnap_bg()
      end,
      desc = "Toggle CodeSnap background",
    },
  },
  opts = {
    save_path = "~/Downloads/",
    has_breadcrumbs = true,
    bg_theme = "sea",
    -- bg_padding = 0, -- 默认无背景
    bg_x_padding = 0,
    bg_y_padding = 0,
  },
  config = function(_, opts)
    local codesnap = require("codesnap")
    codesnap.setup(opts)

    -- 初始化状态
    local show_bg = false -- 默认无背景（因为bg_padding=0）

    -- 创建全局切换函数
    function _G.toggle_codesnap_bg()
      show_bg = not show_bg
      if show_bg then
        -- 显示背景：使用默认padding值
        codesnap.setup({ bg_x_padding = 122, bg_y_padding = 82, bg_theme = opts.bg_theme })
        vim.notify("✅ CodeSnap: Background ENABLED", vim.log.levels.INFO)
      else
        -- 隐藏背景：padding设为0
        codesnap.setup({ bg_x_padding = 0, bg_y_padding = 0, bg_theme = opts.bg_theme })
        vim.notify("🚫 CodeSnap: Background DISABLED", vim.log.levels.INFO)
      end
    end

    -- 也可以创建命令
    vim.api.nvim_create_user_command("CodeSnapToggleBG", function()
      _G.toggle_codesnap_bg()
    end, { desc = "Toggle CodeSnap background" })
  end,
}

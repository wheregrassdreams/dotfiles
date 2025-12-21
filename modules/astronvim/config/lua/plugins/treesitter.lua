-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE
--
-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>", -- 回车开始选择
        node_incremental = "<CR>", -- 回车扩大到父节点
        scope_incremental = "<S-CR>", -- Shift+回车扩大到作用域
        node_decremental = "<BS>", -- 退格缩小
      },
    }
    return opts
  end,
  -- opts = {
  --   ensure_installed = {
  --     "lua",
  --     "vim",
  --     -- add more arguments for adding more treesitter parsers
  --   },
  -- },
}

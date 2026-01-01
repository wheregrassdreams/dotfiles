return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    local buf_utils = require "astrocore.buffer"

    opts.indent = {
      indent = {
        char = "▏",
        highlight = { "SnacksIndent" }, -- 普通竖线只用一个颜色组
      },
      scope = {
        char = "▏",
        highlight = "SnacksIndentScope",
      },
      filter = function(bufnr)
        return buf_utils.is_valid(bufnr)
          and not buf_utils.is_large(bufnr)
          and vim.g.snacks_indent ~= false
          and vim.b[bufnr].snacks_indent ~= false
      end,
      animate = { enabled = true },
    }
  end,
}

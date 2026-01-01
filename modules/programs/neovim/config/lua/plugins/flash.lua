-- flash.nvim
-- Flash enhances the built-in search functionality by showing labels at the end of each match, letting you quickly jump to a specific location


local function jump_diagnostic()
  require("flash").jump({
    matcher = function(win)
      return vim.tbl_map(function(diag)
        return {
          pos = { diag.lnum + 1, diag.col },
          end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
        }
      end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
    end,
    action = function(match, state)
      vim.api.nvim_win_call(match.win, function()
        vim.api.nvim_win_set_cursor(match.win, match.pos)
        vim.diagnostic.open_float()
      end)
      state:restore()
    end,
  })
end

---@type NvPluginSpec
return {
  "folke/flash.nvim",
  event = "VeryLazy",
  vscode = true,
  ---\@type Flash.Config
  opts = {},

  config = function ()
    -- require("flash.nvim").setup()
    vim.api.nvim_set_hl(0, "FlashLabel", {link = "@comment.danger"}) -- 解决当前主题高亮问题
  end,
  -- stylua: ignore
  keys = {
    -- default
    -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    -- 为了兼容ds删除pairs
    { "s", mode = { "n", "x"  }, function() require("flash").jump() end, desc = "Flash" },
    -- TODO: 按键冲突
    -- { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "<c-s>", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },

    -- TODO: 和codelens codeaction noice整合
    -- { "<leader>cd", mode = { "n" }, function() jump_diagnostic() end, desc = "Screen Diagnostic" },
    -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
-- hight
-- FlashMatch    xxx links to Search
-- St_cwd_icon


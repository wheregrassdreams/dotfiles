  return {
    'rafcamlet/nvim-luapad',
    event = "VeryLazy",
    -- requires = "antoinemadec/FixCursorHold.nvim",
    keys = {
      {
        "<leader><leader>`",
        "<cmd>Luapad<CR>",
        desc = "Console (Luapad)",
      }
    }
  }

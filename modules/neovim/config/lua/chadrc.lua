-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(


-- :h nvui

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "rosepine",

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },

  },
  integrations = { "dap", "hop" },
  transparency = false,

}

M.ui = {
}

M.nvdash = {
    load_on_startup = true,
    buttons = {
      { txt = "  Find File", keys = "f", cmd = "Telescope find_files" },
      { txt = "  Recent Files", keys = "r", cmd = "Telescope oldfiles" },
      { txt = "󰈭  Find Word", keys = "w", cmd = "Telescope live_grep" },
      { txt = "󱥚  Themes", keys = "t", cmd = ":lua require('nvchad.themes').open()" },
      -- { txt = "  Projects", keys = "p", cmd = "lua require('telescope').extensions.projects.projects{}" },
      -- { txt = "  Mappings", keys = "m", cmd = "NvCheatsheet" },
      { txt = "  Restore Session", keys = "l", cmd = "SessionLoadLast" },
      { txt = "  Recent Sessions", keys = "s", cmd = "SessionSelect" },
      { txt = "  Quit", keys = "q", cmd = "quit" },

      { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },

      {
        txt = function()
          local stats = require("lazy").stats()
          local ms = math.floor(stats.startuptime) .. " ms"
          return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
        end,
        hl = "NvDashFooter",
        no_gap = true,
      },

      { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
    },
}

return M

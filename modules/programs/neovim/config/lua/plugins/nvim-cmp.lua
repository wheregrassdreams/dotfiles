-- load luasnips + cmp related in insert mode only
---@type NvPluginSpec
return {
  "hrsh7th/nvim-cmp",

  dependencies = {
    "tailwind-tools",
    "onsails/lspkind-nvim",
    -- ...
  },

  opts = function()
    local opts = require("configs.cmp")

    -- tailwindcss config
    opts.formatting = {
      format = require("lspkind").cmp_format({
        before = require("tailwind-tools.cmp").lspkind_format
      }),
    }
    return opts

  --   local cmp = require "nvim-cmp"
  --   cmp.setup.cmdline(":", {
  --     mapping = cmp.mapping.preset.cmdline(),
  --     sources = cmp.config.sources({
  --       { name = "path" },
  --     }, {
  --       {
  --         name = "cmdline",
  --         option = {
  --           ignore_cmds = { "Man", "!", "IncRename" },
  --         },
  --       },
  --     }),
  --   })
  end,

  -- config = function (_, opts)
  --
  -- end

  -- `:` cmdline setup.
  -- config = function()
  --   local cmp = require "nvim-cmp"
  --   cmp.setup.cmdline(":", {
  --     mapping = cmp.mapping.preset.cmdline(),
  --     sources = cmp.config.sources({
  --       { name = "path" },
  --     }, {
  --       {
  --         name = "cmdline",
  --         option = {
  --           ignore_cmds = { "Man", "!", "IncRename" },
  --         },
  --       },
  --     }),
  --   })
  -- end,
}

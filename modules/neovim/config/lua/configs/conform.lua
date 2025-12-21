  -- from https://github.com/BrunoKrugel/dotfiles/blob/master/lua/configs/conform.lua
local options = {
  notify_on_error = false,
  kulala = {
    command = "kulala-fmt",
    args = { "$FILENAME" },
    stdin = false,
  },
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    query = { 'format-queries' },
    http = { "kulala" },
    go = {"goimports", "gofumpt"},
    ["vue"] = { "prettier" },
    ["scss"] = { "prettier" },
    ["less"] = { "prettier" },
    ["yaml"] = { "prettier" },
    ["markdown.mdx"] = { "prettier" },
    ["graphql"] = { "prettier" },
    ["handlebars"] = { "prettier" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
  formatters = {
    prettierd = {
      condition = function()
        return vim.loop.fs_realpath(".prettierrc.js") ~= nil or vim.loop.fs_realpath(".prettierrc.mjs") ~= nil
      end,
    },
  },
}

return options

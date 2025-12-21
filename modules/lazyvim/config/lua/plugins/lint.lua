return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {

        -- args = { "--config", vim.fn.expand("~/.config/nvim/.markdownlint-cli2.yaml"), "--" }, -- 禁用markdown formatter
        args = { "--config", vim.fn.expand("~"), "--" }, -- 禁用markdown formatter
      },
    },
  },
}

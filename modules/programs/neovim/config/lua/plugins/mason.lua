return {
  "williamboman/mason.nvim",
  opts = {

    ensure_installed = {
    -- FIXME: 无法自动安装，会提示找不到
      "gomodifytags",
      "impl",
      "goimports",
      "gofumpt",
      "gomodifytags",
      "impl",
    },
  },
}

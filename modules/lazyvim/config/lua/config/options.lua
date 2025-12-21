-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 配置ssh粘贴板
vim.o.clipboard = "unnamedplus" -- "unnamedplus"使用系统剪贴板，设置为“”禁用系统剪贴板

local osc52 = require("vim.ui.clipboard.osc52")

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = osc52.paste("+"),
    ["*"] = osc52.paste("*"),
  },
}

-- 关闭拼写检查
vim.opt.spelllang = { "en", "cjk" }

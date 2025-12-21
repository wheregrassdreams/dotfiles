require "nvchad.options"

-- add yours here!

vim.g.dap_virtual_text = true
vim.g.bookmark_sign = ""
vim.g.skip_ts_context_commentstring_module = true
vim.g.have_nerd_font = true

vim.o.relativenumber = false

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- vim.opt.clipboard = "" -- 默认禁用系统剪贴板
vim.opt.clipboard = "unnamedplus"
local osc52 = require("vim.ui.clipboard.osc52")
vim.g.clipboard = {
  name = "OSC 52",
  copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
}

-- indent
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0 -- 0 forces same value as tabstop
vim.opt.expandtab = true
vim.opt.autoindent = true

-- cursor
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
vim.opt.guicursor = {
    "n-v-c:block-Cursor/lCursor",   -- 普通、可视和命令模式下使用块状光标
    "i:ver25-Cursor",               -- 插入模式下使用垂直条状光标，宽度为 25%
    "r:hor20",                      -- 替换模式下使用水平条状光标，厚度为 20%
}
-- Folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldcolumn = "1"
-- vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 5
vim.opt.foldnestmax = 5
vim.opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",
  lastline = " ",
  diff = "╱",
}
-- sessions
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.autowrite = true -- Enable auto write

-- -- Prevent issues with some language servers
-- vim.opt.backup = false
-- vim.opt.swapfile = false

-- Always show minimum n lines after/before current line
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 15

-- True color support
vim.opt.termguicolors = true
vim.opt.emoji = false

-- Line break/wrap behaviours
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
-- vim.opt.whichwrap:remove {"h", "l"}
-- vim.opt.whichwrap = "[]<>hl,b,s" -- 光标行尾时可以移动到下一行的按键
vim.o.whichwrap = "" -- 这里取消掉nvchad默认的配置

-- Undo
vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.updatetime = 100
vim.opt.lazyredraw = false
-- vim.opt.iskeyword:append { "_", "@", ".", "-" }
vim.opt.path:append { "**", "lua", "src" }
vim.opt.grepprg = "rg --vimgrep"

vim.opt.updatetime = 200 -- Save swap file and trigger CursorHold
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.winminwidth = 5 -- Minimum window width

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
  vim.opt.foldmethod = "expr"
  vim.opt.foldtext = ""
else
  vim.opt.foldmethod = "indent"
end

-- Prevent auto comment new line
vim.opt.formatoptions:remove { "c", "r", "o" }

vim.opt.jumpoptions = "stack"

-- vim.cmd [[
--  set jumpoptions+=stack
-- ]]

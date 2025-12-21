-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd
-- local augroup = vim.api.nvim_create_augroup

-- General Settings
-- local general = augroup("General", { clear = true })

-- Add autocmd for macOS to switch input method to ABC when entering normal mode
if vim.fn.has("mac") and vim.env.SSH_CONNECTION == nil then
  -- local imselect_bin = "/usr/local/bin/im-select"
  local imselect_bin = "im-select" -- "/opt/homebrew/bin/im-select"
  if not vim.fn.executable(imselect_bin) then
    return
  end
  autocmd({ "InsertLeave", "FocusGained" }, {
    pattern = "*",
    callback = function()
      -- 只有在需要时才切换
      if vim.fn.system(imselect_bin):match "com.apple.keylayout.ABC" ~= nil then
        return
      end
      vim.fn.system(imselect_bin .. " com.apple.keylayout.ABC")
    end,
  })
end

-- FIXME: 有时不起作用，怀疑是事件顺序问题
autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove { "c", "r", "o" }
  end,
  -- group = general,
  desc = "Prevent auto comment new line",
})

-- wrap and check for spell in text filetypes
autocmd("FileType", {
  -- group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    -- vim.opt_local.spell = false
    -- vim.opt_local.linebreak = true  -- 为更好地换行，避免单词被截断
    vim.opt_local.whichwrap = "[]<>hl,b,s" -- allow automatically go to next line

  end,
})


-- 退出时自动关闭nvimtree
autocmd("QuitPre", {
  callback = function()
    local has_tree = false
    local n_win = 0
    for _, win in pairs(vim.api.nvim_list_wins()) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
      -- for noice.nvim
      if bufname == nil or bufname == "" then goto continue end
      if bufname:match("NvimTree_") ~= nil then
        has_tree = true
      end
      n_win = n_win + 1
      ::continue::
    end
    if n_win <= 2 and has_tree then require("nvim-tree.api").tree.close() end
  end
})


-- Highlight on yank
autocmd("TextYankPost", {
  -- group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- prevent weird snippet jumping behavior
-- https://github.com/L3MON4D3/LuaSnip/issues/258
-- nvchad 自带了
-- autocmd({ "ModeChanged" }, {
--   pattern = { "s:n", "i:*" },
--   callback = function()
--     if
--       require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
--       and not require("luasnip").session.jump_active
--     then
--       require("luasnip").unlink_current()
--     end
--   end,
-- })

-- Delete [No Name] buffers,
autocmd("BufHidden", {
  callback = function(event)
    if event.file == "" and vim.bo[event.buf].buftype == "" and not vim.bo[event.buf].modified then
      vim.schedule(function()
        pcall(vim.api.nvim_buf_delete, event.buf, {})
      end)
    end
  end,
})

-- Hide cursorline in insert mode
autocmd({ "InsertLeave" }, {
  command = "set cursorline",
})
autocmd({ "InsertEnter" }, {
  command = "set nocursorline",
})

-- Automatically update changed file in Vim
-- Triger `autoread` when files changes on disk
-- https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
-- https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = [[silent! if mode() != 'c' && !bufexists("[Command Line]") | checktime | endif]],
})

-- Notification after file change
-- https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
-- autocmd("FileChangedShellPost", {
--   command = [[echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None]],
-- })


-- 设置工作目录
autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)  -- 获取第一个参数
    local isdirectory

    if arg and arg ~= "" then
--       local dir = vim.fn.expand(vim.fn.argv(0))
      isdirectory = vim.fn.isdirectory(arg) == 1
---@diagnostic disable-next-line: param-type-mismatch
      -- isfile = vim.fn.filereadable(arg) == 1
    end

    if isdirectory then
      vim.cmd("cd " .. arg)
    end

    -- 获取当前文件的 Git 根目录（如果存在）
    -- local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    -- if git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1 then
    --   vim.cmd("cd " .. git_root)
    --   print("Changed working directory to Git root: " .. git_root)
    -- end

    if isdirectory then
      require("nvim-tree.api").tree.open()
    end
  end,
})

-- 识别http
autocmd({"BufRead","BufNewFile"}, {
  pattern = {'*.http', '*.rest'},
  command = "set filetype=http"
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
  -- group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  -- group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "snacks_win",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- make it easier to close man-files when opened inline
autocmd("FileType", {
  -- group = augroup("man_unlisted"),
  pattern = { "man" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
  -- group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})



-- FIXME: 没有用或者可能冲突了

-- Somewhere in your config
-- local persisted = require("persisted")
-- vim.api.nvim_create_autocmd("VimEnter", {
--   nested = true,
--   callback = function()
--     if vim.g.started_with_stdin then
--       return
--     end
--
--     local forceload = false
--     if vim.fn.argc() == 0 then
--       forceload = true
--     elseif vim.fn.argc() == 1 then
-- ---@diagnostic disable-next-line: param-type-mismatch
--       local dir = vim.fn.expand(vim.fn.argv(0))
--       if dir == '.' then
--         dir = vim.fn.getcwd()
--       end
--
--       if vim.fn.isdirectory(dir) ~= 0 then
--         forceload = true
--       end
--     end
--
--     persisted.autoload({ force = forceload })
--   end,
-- })

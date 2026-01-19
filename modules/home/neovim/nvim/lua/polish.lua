-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local autocmd = vim.api.nvim_create_autocmd

-- 智能切换输入法
-- Add autocmd for macOS to switch input method to ABC when entering normal mode
if vim.fn.has "mac" and vim.env.SSH_CONNECTION == nil then
  -- local imselect_bin = "/usr/local/bin/im-select"
  local imselect_bin = "im-select" -- "/opt/homebrew/bin/im-select"
  if not vim.fn.executable(imselect_bin) then return end
  autocmd({ "InsertLeave", "FocusGained" }, {
    pattern = "*",
    callback = function()
      -- 只有在需要时才切换
      if vim.fn.system(imselect_bin):match "com.apple.keylayout.ABC" ~= nil then return end
      vim.fn.system(imselect_bin .. " com.apple.keylayout.ABC")
    end,
  })
end

-- Resize splits if window got resized
autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
})

-- q 关闭非编辑窗口
autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(win).relative then return end

    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype

    local non_edit = {
      help = true,
      qf = true,
      NvimTree = true,
      dashboard = true,
      trouble = true,
      packer = true,
      ["neo-tree"] = true,
      ["TelescopeResults"] = true,
      ["TelescopePrompt"] = true,
      ["fugitive"] = true,
      ["diff"] = true,
      ["git"] = true,
      ["toggleterm"] = true,
      ["aerial"] = true,
      avante = true,
    }
    local non_edit_bt = { quickfix = true, terminal = true, prompt = true, location = true }

    if non_edit[ft] or non_edit_bt[bt] then
      vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
    end
  end,
})
-- local snacks = require "snacks"
-- snacks.picker("frecency", {
--   title = "Frecent Files",
--   -- snacks 这边定义如何触发，真正逻辑交给 telescope
--   action = function() require("telescope").extensions.frecency.frecency() end,
-- })

-- TODO: markdown 高亮
-- 覆盖 Treesitter 的高亮为黑色/灰色
-- vim.api.nvim_set_hl(0, "@markup.list.markdown", { fg = "#cacaca" }) -- 列表符号灰色
-- vim.api.nvim_set_hl(0, "@spell.markdown", { fg = "#444444" }) -- 拼写灰色
-- vim.api.nvim_set_hl(0, "@_label.markdown_inline", { fg = "#333333" }) -- inline label
-- vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { fg = "#333333" })
-- vim.api.nvim_set_hl(0, "@keyword.directive.markdown", { fg = "#cacaca" })
-- -- vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#e8e8e8" })
-- -- vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#000000", bold = true })
-- -- vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#000000", bold = true })
-- vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#333333", fg = "#ffffff" })
-- vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#ffffff", bold = true })
-- -- vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#ffffff", bold = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.number = false -- 关闭绝对行号
    vim.opt_local.relativenumber = false -- 关闭相对行号
    require("snacks.indent").disable()
  end,
})

-- 自动同步外部文件变化
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  command = "checktime",
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function() vim.notify("File reloaded from disk", vim.log.levels.INFO) end,
})

vim.api.nvim_create_user_command("CopyPathLine", function(opts)
  local path = vim.fn.expand "%:p" -- 绝对路径
  local line = vim.fn.line "." -- 当前行号
  local full = path .. ":" .. line

  -- 复制到系统剪贴板（+寄存器）
  vim.fn.setreg("+", full)
  vim.notify("📋 Copied: " .. full, vim.log.levels.INFO, { title = "CopyPathLine" })
end, {
  desc = "Copy current file path with line number to clipboard",
})

-- require "orbital_remote"

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- General Settings
local general = augroup("General", { clear = true })

-- 智能切换输入法
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
      if vim.fn.system(imselect_bin):match("com.apple.keylayout.ABC") ~= nil then
        return
      end
      vim.fn.system(imselect_bin .. " com.apple.keylayout.ABC")
    end,
  })
end

autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
  group = general,
  desc = "Disable New Line Comment",
})

autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = false
  end,

  desc = "Disable spell checking for markdown and txt files",
})

-- autocmd("QuitPre", {
--   callback = function()
--     local n_win = 0
--     local invalid_win = {}
--     local wins = vim.api.nvim_list_wins()
--     for _, w in ipairs(wins) do
--       local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
--       if bufname ~= "" then -- 不知道为什么会有名字为空的buffer
--         if bufname:match("filesystem") ~= nil then
--           table.insert(invalid_win, w)
--         end
--         n_win = n_win + 1
--       end
--     end
--     if #invalid_win == n_win - 1 then
--       for _, w in ipairs(invalid_win) do
--         vim.api.nvim_win_close(w, true)
--       end
--     end
--   end,
--
--   desc = "Auto close NeoTree window before quit",
-- })

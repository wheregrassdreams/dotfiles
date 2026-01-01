-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- 优化window resize逻辑
local resize = function(win, amt, dir)
  return function()
    require("winresize").resize(win, amt, dir)
  end
end
vim.keymap.set("n", "<C-Left>", resize(0, 2, "left"))
vim.keymap.set("n", "<C-Down>", resize(0, 1, "down"))
vim.keymap.set("n", "<C-Up>", resize(0, 1, "up"))
vim.keymap.set("n", "<C-Right>", resize(0, 2, "right"))

-- vim.keymap.set("n", "<c-t>", function()
--   for _, buf in ipairs(vim.api.nvim_list_bufs()) do
--     local buf_name = vim.api.nvim_buf_get_name(buf)
--     local buf_ft = vim.bo[buf].filetype
--     local buf_type = vim.bo[buf].buftype
--
--     -- local is_dir = buf_name ~= "" and buf_ft == "" and buf_type == "" and buf_name:match("/[^/]+$")
--     -- local is_dir = buf_name ~= "" and buf_ft == "" and buf_type == ""
--
--     vim.notify("buffer: " .. buf_name .. "\nfiletype: " .. buf_ft .. "\ntype: " .. buf_type)
--   end
-- end)

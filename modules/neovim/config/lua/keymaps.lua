-- require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

-- map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader><leader>", "", { desc = "More Tools" })

--- Buffer commands
map("n", "<leader><leader><leader>", "<cmd>Telescope find_files<cr>", { desc = "Telescope find files" })

-- TODO: 添加autocmd，在映射只在折叠开启的情况下生效

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- map("n", "$", "g$")
-- map("n", "^", "g^")
-- map("n", "0", "g0")

-- -- better up/down
-- map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
-- map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
-- map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

map("n", "<C-h>", "<C-w>h", { desc = "Switch Window Left" })
map("n", "<C-l>", "<C-w>l", { desc = "Switch Window Right" })
map("n", "<C-j>", "<C-w>j", { desc = "Switch Window Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Switch Window Up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear Highlights" })

-- map("n", "<leader>u", "", { desc = "UI" })
-- map("n", "<leader>un", "<cmd>set nu!<CR>", { desc = "Toggle Line Number" })
map("n", "<leader>ur", "<cmd>set rnu!<CR>", { desc = "Toggle Relative Number" })
map("n", "<leader>uf", function ()
    if vim.o.foldcolumn ~= "0" then vim.o.foldcolumn="0" else vim.o.foldcolumn="2" end
end, { desc = "Toggle Folder Column" })
map("n", "<leader>ut", function()
  require("nvchad.themes").open()
end, { desc = "telescope nvchad themes" })
-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
-- map(
--   "n",
--   "<leader>ur",
--   "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
--   { desc = "Redraw / Clear hlsearch / Diff Update" }
-- )

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Git
map("n", "<leader>g", "", { desc = "Git" })
map("n", "<leader>gm", "<cmd>Telescope git_commits<CR>", { desc = "Git Commits" })
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git Status" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview Hunk" })
map("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Current Line Blame" })
-- map("n", "<leader>gg", function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
-- map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
-- map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
-- map("n", "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })
-- map("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit Current File History" })
-- map("n", "<leader>gl", function() Snacks.lazygit.log({ cwd = LazyVim.root.git() }) end, { desc = "Lazygit Log" })
-- map("n", "<leader>gL", function() Snacks.lazygit.log() end, { desc = "Lazygit Log (cwd)" })

-- Telescope
map("n", "<leader>f", "Telescope", { desc = "Find (Telescope)" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
-- map("n", "<leader>fd", "", { desc = "Change cwd" })
map("n", "<leader>fa", "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>", { desc = "Telescope Find All Files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "Find Text" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Telescope Help Page" })
map("n", "<leader>fa", "<cmd>Telescope marks<CR>", { desc = "Find Marks" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Find Recent Files" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "Find Text (Current Buffer)" })
map("n", "<leader>fc", "<cmd>Telescope commands<cr>", { desc = "Telescope Find Commands" })
map("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "Telescope Find Bookmarks" })
map("n", "<leader>fn", "<cmd>Telescope notify<cr>", { desc = "Find Notifications" })

-- 还不知道有什么用
-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
-- map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- Windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- AI
map("n", "<leader>a", "", { desc = "AI" })

-- Help
map("n", "<leader>h", "", { desc = "Help" })
map("n", "<leader>hc", "<cmd>Telescope commands<cr>", { desc = "Find Commands" })
map("n", "<leader>hk", "<cmd>Telescope keymaps<cr>", { desc = "Find Keymaps" })
map("n", "<leader>ht", "<cmd>Telescope help_tags<CR>", { desc = "Telescope Help Page" })
map("n", "<leader>hc", "<cmd>NvCheatsheet<CR>", { desc = "Toggle Nvcheatsheet" })
map("n", "<leader>hwK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
map("n", "<leader>hwk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

-- Terminal
map("n", "<leader>t",  "", { desc = "Terminal" })
map("n", "<leader>tt", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
map("n", "<leader>th", function() require("nvchad.term").new { pos = "sp" } end, { desc = "Terminal New Horizontal Term" })
map("n", "<leader>tv", function() require("nvchad.term").new { pos = "vsp" } end, { desc = "Terminal New Vertical Term" })
-- map({ "n", "t" }, "<A-v>", function() require("nvchad.term").toggle { pos = "vsp", id = "vtoggleTerm" } end, { desc = "terminal toggleable vertical term" })
map({ "n", "t" }, "<C-`>", function() require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" } end, { desc = "terminal toggleable horizontal term" })
map({ "n", "t" }, "<C-/>", function() require("nvchad.term").toggle { pos = "float", id = "floatTerm" } end, { desc = "terminal toggle floating term" })

-- TODO: 排除filetype=lazygit
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

map("n", "<leader>=", "", { desc = "Format" })
map("n", "<leader>==", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "Format File" })

-- TODO: 排除filetype=Avante

-- Buffers
-- luaship中跳转时会误触
map("n", "<tab>",      function() require("nvchad.tabufline").next() end, { desc = "Buffer Goto Next" })
map("n", "<S-tab>",    function() require("nvchad.tabufline").prev() end, { desc = "Buffer Goto Prev" })
map("n", "<S-l>",      function() require("nvchad.tabufline").next() end, { desc = "Buffer Goto Next" })
map("n", "<S-h>",      function() require("nvchad.tabufline").prev() end, { desc = "Buffer Goto Prev" })
map("n", "<Leader>b",  "", { desc = "Buffer" })
map("n", "<leader>bl", "<cmd>e#<cr>", { desc = "Buffer Goto Last" })
map("n", "<Leader>bd", function () require("nvchad.tabufline").close_buffer() end, { desc = "Buffer Close" })
map("n", "<leader>bf", "<cmd>Telescope buffers<CR>", { desc = "Find Buffers" })
-- quick shortcut
map("n", "<leader>`",  "<cmd>e#<cr>", { desc = "Buffer Goto Last" })
map("n", "<leader>'",  require("nvchad.tabufline").close_buffer, { desc = "Close Buffer" })
map("n", "<leader>;",  "<cmd>Telescope buffers<CR>", { desc = "Switch Buffers" })

-- Code action
map("n", "<Leader>c",  "", { desc = "CodeAction/CodeLens" })

-- Debug
map("n", "<Leader>d",  "", { desc = "Debug" })

-- Session
map("n", "<Leader>q",  "", { desc = "Session" })

-- NvimTree
map("n", "<Leader>e",  function () require("nvim-tree.api").tree.open() end, { desc = "NvimTree Windows" })
map("n", "<C-n>",      function () require("nvim-tree.api").tree.toggle() end, { desc = "Nvimtree Toggle" })

-- Lazy.nvim
map("n", "<Leader>L",  "<cmd>Lazy<CR>", { desc = "Lazy" })

-- Better indenting
map("v", ">", ">gv")
map("v", "<", "<gv")
map("v", "y", "ygv<ESC>") -- 复制后光标保持在原来的位置


-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" }) -- 使用flash
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
-- map("n", "\\t", function ()
--   vim.ui.select({'apple', 'banana', 'mango'}, {
--   prompt = "Title",
--   telescope = require("telescope.themes").get_cursor(),
-- }, function(selected) end)
-- end, { desc = "Test" })
--
--
-- More advanced example that also highlights diagnostics:

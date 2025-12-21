-- 自定义Session管理器
local M = {}

-- 配置选项
M.config = {
  session_dir = vim.fn.stdpath("data") .. "/sessions",
  ignore_buftypes = { "terminal", "prompt", "quickfix", "nofile", "help" },
  ignore_filetypes = { "netrw", "dirvish", "TelescopePrompt", "fugitive", "gitcommit" },
  ignore_patterns = { "^term://", "^fugitive://", "^nvim://", "^git://" },
  autosave = {
    on_exit = true,
    on_dir_change = false,
  },
}

function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
  vim.fn.mkdir(M.config.session_dir, "p")
  M._create_commands()
  M._setup_autocmds()
end

function M._create_commands()
  vim.api.nvim_create_user_command("SessionSave", function(opts)
    M.save_session(opts.args)
  end, { nargs = "?", desc = "保存当前会话" })

  vim.api.nvim_create_user_command("SessionLoad", function(opts)
    M.load_session(opts.args)
  end, { nargs = "?", desc = "加载会话" })

  vim.api.nvim_create_user_command("SessionDelete", function(opts)
    M.delete_session(opts.args)
  end, { nargs = 1, desc = "删除会话" })

  vim.api.nvim_create_user_command("SessionList", function()
    M.list_sessions()
  end, { desc = "列出所有会话" })
end

function M._setup_autocmds()
  if M.config.autosave.on_exit then
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        M.save_session("autosave")
      end,
    })
  end
end

-- 智能buffer过滤
function M._should_save_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
  local listed = vim.api.nvim_buf_get_option(bufnr, "buflisted")

  if vim.tbl_contains(M.config.ignore_buftypes, buftype) then
    return false
  end

  if vim.tbl_contains(M.config.ignore_filetypes, filetype) then
    return false
  end

  for _, pattern in ipairs(M.config.ignore_patterns) do
    if bufname:match(pattern) then
      return false
    end
  end

  if bufname == "" and not modified then
    return false
  end

  if not listed and not modified then
    return false
  end

  return buftype == "" and bufname ~= "" and vim.fn.filereadable(bufname) == 1
end

function M._cleanup_before_loading()
  -- 先关闭所有窗口，只保留当前窗口（避免 buffer 被占用）
  vim.cmd("only!")

  -- 获取所有 buffer
  local bufs = vim.api.nvim_list_bufs()

  for _, bufnr in ipairs(bufs) do
    if not vim.api.nvim_buf_is_valid(bufnr) then
      goto continue
    end

    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
    local listed = vim.api.nvim_buf_get_option(bufnr, "buflisted")

    -- 保留特殊 buffer（terminal, prompt, help, quickfix, 不可删除的）
    if vim.tbl_contains({ "terminal", "prompt", "help", "quickfix", "nofile" }, buftype) then
      goto continue
    end

    -- 保留“已修改且用户可能关心”的 buffer（给出提示或跳过删除）
    if modified and bufname ~= "" then
      print("⚠️  跳过删除已修改的 buffer: " .. bufname)
      goto continue
    end

    -- 删除其他所有 buffer（包括未列出的、空名的、未修改的）
    -- 先确保没有窗口关联
    local winids = vim.fn.win_findbuf(bufnr)
    for _, winid in ipairs(winids) do
      if winid ~= vim.api.nvim_get_current_win() then
        vim.api.nvim_win_close(winid, true)
      end
    end

    -- 强制删除 buffer
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })

    ::continue::
  end

  -- 清理后，确保只剩一个空 buffer
  vim.cmd("enew!")
end

function M._get_window_layout()
  local layout = {}
  local tabpages = vim.api.nvim_list_tabpages()

  for _, tabnr in ipairs(tabpages) do
    local wins = vim.api.nvim_tabpage_list_wins(tabnr)
    local tab_layout = {
      tabnr = tabnr,
      wins = {},
      is_current = (tabnr == vim.api.nvim_get_current_tabpage()),
    }

    for _, winid in ipairs(wins) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- 只保存关联真实文件的窗口
      if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
        local win_config = vim.api.nvim_win_get_config(winid)
        local width = vim.api.nvim_win_get_width(winid)
        local height = vim.api.nvim_win_get_height(winid)
        local cursor = vim.api.nvim_win_get_cursor(winid) -- {行, 列}

        table.insert(tab_layout.wins, {
          winid = winid,
          bufname = bufname,
          width = width,
          height = height,
          row = win_config.row,
          col = win_config.col,
          cursor_line = cursor[1],
          cursor_col = cursor[2] + 1, -- 转 1-based
          is_current = (winid == vim.api.nvim_get_current_win()),
        })
      end
    end

    if #tab_layout.wins > 0 then
      table.insert(layout, tab_layout)
    end
  end

  return layout
end

-- 获取要保存的buffer列表（包含光标位置）
function M._get_buffers_to_save()
  local buffers = {}
  local current_bufnr = vim.api.nvim_get_current_buf()

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if M._should_save_buffer(bufnr) then
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- ✅ 关键修复：从窗口获取实时光标位置
      local winids = vim.fn.win_findbuf(bufnr)
      local line, col = 1, 0 -- 默认值
      local top_line = 1 -- 窗口顶部行号，用于设置视图位置

      if #winids > 0 then
        -- 取第一个窗口的光标位置（如果有多个窗口显示同一 buffer，取第一个）
        local winid = winids[1]
        local cursor = vim.api.nvim_win_get_cursor(winid) -- {行, 列}，行是1-based，列是0-based
        line, col = cursor[1], cursor[2]

        top_line = vim.api.nvim_win_call(winid, function()
          return vim.fn.line("w0") -- 当前窗口第一行的 buffer 行号
        end)
      else
        -- 如果 buffer 不在任何窗口中，回退到 buffer 的 '.' mark
        local mark = vim.api.nvim_buf_get_mark(bufnr, ".")
        line, col = mark[1], mark[2]
        top_line = line -- 无窗口时，顶部行 = 光标行
      end

      local buf_info = {
        name = bufname,
        line = line, -- 行（1-based，直接可用）
        col = col + 1, -- 列（转成 1-based）
        top_line = top_line,
        modified = vim.api.nvim_buf_get_option(bufnr, "modified"),
        is_current = (bufnr == current_bufnr),
        -- win_info = M._get_buffer_window_info(bufnr), -- 如果不用可以注释
      }
      table.insert(buffers, buf_info)
    end
  end
  return buffers
end

-- 获取buffer的窗口信息
function M._get_buffer_window_info(bufnr)
  local win_info = nil
  local winids = vim.fn.win_findbuf(bufnr)

  if #winids > 0 then
    local winid = winids[1] -- 取第一个窗口
    local win_config = vim.api.nvim_win_get_config(winid)
    win_info = {
      winid = winid,
      top_line = vim.fn.line("w0", winid), -- 窗口顶部行号
      current_line = vim.fn.line(".", winid), -- 当前行号
    }
  end

  return win_info
end

-- 生成session内容（修复光标位置保存）
function M._generate_session_content()
  local lines = {
    '" =================================',
    '" 自定义Neovim Session文件',
    '" 生成时间: ' .. os.date("%Y-%m-%d %H:%M:%S"),
    '" =================================',
    "",
  }

  -- 恢复工作目录

  table.insert(lines, '" 工作目录')
  table.insert(lines, "cd " .. vim.fn.getcwd())
  table.insert(lines, "")

  -- 恢复buffers（包含光标位置）
  table.insert(lines, '" 缓冲区和光标位置管理')
  local buffers = M._get_buffers_to_save()
  local current_buffer = nil

  for _, buf in ipairs(buffers) do
    table.insert(lines, string.format("badd +%d %s", buf.line, vim.fn.fnameescape(buf.name)))

    if buf.is_current then
      current_buffer = buf
    end
  end
  table.insert(lines, "")

  -- -- 恢复跳转列表
  -- local jumplist = M._get_jumplist()
  -- if #jumplist > 0 then
  --   table.insert(lines, "")
  --   table.insert(lines, '" 恢复跳转列表')
  --   for _, jump in ipairs(jumplist) do
  --     table.insert(lines, string.format("keepjumps silent edit %s", vim.fn.fnameescape(jump.bufname)))
  --     table.insert(lines, string.format("keepjumps call cursor(%d, %d)", jump.lnum, jump.col))
  --   end
  -- end

  -- 切换到当前buffer
  if not current_buffer and #buffers > 0 then
    current_buffer = buffers[1]
  end
  if current_buffer then
    table.insert(lines, '" 切换到当前buffer')
    table.insert(lines, "edit " .. vim.fn.fnameescape(current_buffer.name))

    table.insert(lines, "")
    table.insert(lines, '" 恢复窗口滚动和光标位置')
    -- ✅ 恢复窗口滚动位置
    if current_buffer.top_line and current_buffer.top_line > 0 then
      -- 确保 top_line 不超过光标行（避免光标被挤出视野）
      local safe_top = math.min(current_buffer.top_line, current_buffer.line)
      table.insert(lines, string.format("call cursor(%d, 0)", safe_top))
      table.insert(lines, "normal! zt")
    else
      table.insert(lines, "normal! zz")
    end

    -- 恢复光标位置
    table.insert(lines, "call cursor(" .. current_buffer.line .. ", " .. current_buffer.col .. ")")
    table.insert(lines, "")
  end

  -- 修改状态恢复
  local exists_modified = false
  for _, buf in ipairs(buffers) do
    if buf.modified then
      if not exists_modified then
        table.insert(lines, '" 恢复修改状态')
      end
      exists_modified = true
      table.insert(lines, string.format('call setbufvar(bufnr("%s"), "&modified", 1)', vim.fn.fnameescape(buf.name)))
    end
  end
  if exists_modified then
    table.insert(lines, "")
  end

  -- 恢复 viminfo（寄存器、标记等）
  table.insert(lines, '" 恢复寄存器、标记等')
  table.insert(lines, "rviminfo!")

  return table.concat(lines, "\n")
end

-- 保存session
function M.save_session(session_name)
  if not session_name or session_name == "" then
    session_name = vim.fn.input("会话名称: ")
    if session_name == "" then
      return
    end
  end

  local session_path = M.config.session_dir .. "/" .. session_name .. ".vim"
  local content = M._generate_session_content()

  local file = io.open(session_path, "w")
  if file then
    file:write(content)
    file:close()
    print("会话已保存: " .. session_name)
    return true
  else
    print("保存会话失败: " .. session_name)
    return false
  end
end

-- 加载session
function M.load_session(session_name)
  if not session_name or session_name == "" then
    local sessions = M.get_session_list()
    if #sessions == 0 then
      print("没有可用的会话")
      return
    end

    vim.ui.select(sessions, {
      prompt = "选择要加载的会话:",
    }, function(choice)
      if choice then
        M._load_session_file(choice)
      end
    end)
    return
  end

  M._load_session_file(session_name)
end

function M._load_session_file(session_name)
  local session_path = M.config.session_dir .. "/" .. session_name .. ".vim"
  if not vim.fn.filereadable(session_path) then
    print("会话不存在: " .. session_name)
    return
  end

  M._cleanup_before_loading()
  vim.cmd("source " .. vim.fn.fnameescape(session_path))
  M._cleanup_after_loading()
  print("会话已加载: " .. session_name)
end

function M._cleanup_after_loading()
  local current_bufnr = vim.api.nvim_get_current_buf()

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if not vim.api.nvim_buf_is_valid(bufnr) or bufnr == current_bufnr then
      goto continue
    end

    local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
    local listed = vim.api.nvim_buf_get_option(bufnr, "buflisted")

    -- 保留所有特殊 buftype（插件 buffer）
    if buftype ~= "" then
      goto continue
    end

    -- 保留有文件名的 buffer（Session 中的文件）
    if bufname ~= "" and bufname ~= "[No Name]" and bufname ~= "[Scratch]" then
      goto continue
    end

    -- 保留已修改的 buffer（安全第一）
    if modified then
      print("⚠️  保留已修改的 buffer: " .. bufnr)
      goto continue
    end

    -- 删除 [No Name] / [Scratch] 等无用 buffer
    local winids = vim.fn.win_findbuf(bufnr)
    for _, winid in ipairs(winids) do
      if winid ~= vim.api.nvim_get_current_win() then
        pcall(vim.api.nvim_win_close, winid, true)
      end
    end
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })

    ::continue::
  end
end

function M.delete_session(session_name)
  local session_path = M.config.session_dir .. "/" .. session_name .. ".vim"
  if vim.fn.delete(session_path) == 0 then
    print("会话已删除: " .. session_name)
  else
    print("删除会话失败: " .. session_name)
  end
end

function M.get_session_list()
  local sessions = {}
  local pattern = M.config.session_dir .. "/*.vim"
  local files = vim.fn.glob(pattern, true, true)

  for _, file in ipairs(files) do
    table.insert(sessions, vim.fn.fnamemodify(file, ":t:r"))
  end

  return sessions
end

function M.list_sessions()
  local sessions = M.get_session_list()
  if #sessions == 0 then
    print("没有可用的会话")
    return
  end

  print("可用会话:")
  for i, name in ipairs(sessions) do
    print(string.format("  %d. %s", i, name))
  end
end

-- 设置默认配置
M.setup()

return M

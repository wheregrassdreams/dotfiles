local M = {}

-- 将状态文件放在 cache 目录
local state_file = vim.fn.stdpath("cache") .. "/nvim_state.json"

-- 读取状态文件
function M.load()
  local ok, data = pcall(function()
    if vim.fn.filereadable(state_file) == 1 then
      return vim.json.decode(vim.fn.readfile(state_file))
    end
    return {}
  end)
  return ok and data or {}
end

-- 保存状态到文件
function M.save(state)
  -- 确保 cache 目录存在
  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
  pcall(vim.fn.writefile, { vim.json.encode(state) }, state_file)
end

-- 获取状态值
function M.get(key, default)
  local state = M.load()
  return state[key] or default
end

-- 设置状态值
function M.set(key, value)
  local state = M.load()
  state[key] = value
  M.save(state)
end

-- 切换状态值
function M.toggle(key, default)
  local current = M.get(key, default)
  local new_value = not current
  M.set(key, new_value)
  return new_value
end

-- 批量获取状态
function M.get_all()
  return M.load()
end

-- 批量设置状态
function M.set_all(new_state)
  M.save(new_state)
end

-- 清除所有状态
function M.clear()
  M.save({})
  vim.notify("State cleared", vim.log.levels.INFO)
end

-- 创建命令来管理状态
vim.api.nvim_create_user_command("StateClear", M.clear, { desc = "Clear all persisted state" })

vim.api.nvim_create_user_command("StateShow", function()
  local state = M.load()
  print(vim.inspect(state))
end, { desc = "Show current state" })

return M

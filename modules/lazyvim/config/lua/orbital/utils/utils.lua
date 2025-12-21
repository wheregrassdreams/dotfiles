-- orbital/utils.lua
-- Utility Functions

local M = {}

-- Logging function
function M.log(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[Orbital] " .. msg, level)
end

-- Async job runner using vim.fn.jobstart
function M.run_async_command(cmd, on_success, on_error, opts)
  opts = opts or {}
  local stdout_data = {}
  local stderr_data = {}
  
  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    cwd = opts.cwd,
    on_stdout = function(_, data)
      if data then vim.list_extend(stdout_data, data) end
    end,
    on_stderr = function(_, data)
      if data then vim.list_extend(stderr_data, data) end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          local stdout = table.concat(stdout_data, '\n')
          if on_success then on_success(stdout) end
        else
          local stderr = table.concat(stderr_data, '\n')
          if on_error then on_error(stderr, exit_code) end
        end
      end)
    end
  })
  
  return job_id
end

-- Create temporary file
function M.create_temp_file()
  local temp_dir = vim.fn.tempname()
  os.execute("mkdir -p " .. vim.fn.fnamemodify(temp_dir, ":h"))
  return temp_dir
end

-- Read entire file
function M.read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  
  local content = file:read("*all")
  file:close()
  
  return content
end

-- Write content to file
function M.write_file(path, content)
  local file = io.open(path, "w")
  if not file then
    return false
  end
  
  file:write(content)
  file:close()
  
  return true
end

-- Table utility functions
function M.table_extend(dst, src)
  for k, v in pairs(src) do
    dst[k] = v
  end
  return dst
end

function M.table_count(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

-- String utility functions
function M.trim(str)
  return str:match("^%s*(.-)%s*$")
end

function M.split(str, delimiter)
  local result = {}
  local pattern = "(.-)" .. delimiter
  local last_end = 1
  local s, e, cap = str:find(pattern, 1)
  
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(result, cap)
    end
    last_end = e + 1
    s, e, cap = str:find(pattern, last_end)
  end
  
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(result, cap)
  end
  
  return result
end

-- Path utility functions
function M.join_path(...)
  local parts = {...}
  local result = table.concat(parts, "/")
  -- Clean up multiple slashes
  result = result:gsub("//+", "/")
  return result
end

function M.basename(path)
  return path:match("([^/]+)$") or path
end

function M.dirname(path)
  return path:match("(.*)/[^/]+$") or "."
end

return M

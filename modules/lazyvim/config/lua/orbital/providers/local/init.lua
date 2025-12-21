-- orbital/client/providers/local_provider/init.lua
-- Local Provider Implementation (FileSystem + Command interfaces)

local Provider = require("orbital.client.providers.provider")
local Utils = require("orbital.utils")

-- Import interfaces
local FileSystemInterface = require("orbital.interfaces.filesystem")
local CommandInterface = require("orbital.interfaces.command")

local LocalProvider = setmetatable({}, { __index = Provider })
LocalProvider.__index = LocalProvider

function LocalProvider.new(uri)
  local self = setmetatable(Provider.new(uri), LocalProvider)
  self.type = "local"
  
  -- Register supported interfaces
  self:add_interface("filesystem", FileSystemInterface)
  self:add_interface("command", CommandInterface)
  
  return self
end

-- ============================================================================
-- Connection Management (Direct - no network)
-- ============================================================================

function LocalProvider:connect(uri, callback)
  self.connected = true
  Utils.log("✓ Connected to local filesystem")
  if callback then callback(true, "Local filesystem ready") end
  return true
end

function LocalProvider:disconnect(callback)
  self.connected = false
  Utils.log("Disconnected from local filesystem")
  if callback then callback(true, "Disconnected") end
end

function LocalProvider:is_connected()
  return self.connected
end

function LocalProvider:get_connection_info()
  return {
    type = "local",
    uri = self.uri,
    status = self.connected and "connected" or "disconnected",
    connected_at = self.connected and os.time() or nil
  }
end

-- ============================================================================
-- FileSystem Interface Implementation
-- ============================================================================

function LocalProvider:read_file(path, callback)
  vim.schedule(function()
    local success, content = pcall(function()
      local lines = vim.fn.readfile(path)
      return table.concat(lines, "\n")
    end)

    if success then
      callback(true, content)
    else
      callback(false, "Failed to read file: " .. content)
    end
  end)
end

function LocalProvider:write_file(path, content, callback)
  vim.schedule(function()
    local lines = vim.split(content, "\n", { trimempty = false })
    local success, err = pcall(vim.fn.writefile, lines, path)

    if success then
      callback(true, "File saved successfully")
    else
      callback(false, "Failed to write file: " .. err)
    end
  end)
end

function LocalProvider:list_files(path, callback)
  self:execute_command({"find", path, "-type", "f", "-not", "-path", "*/.*"}, function(success, output)
    if success then
      local files = vim.split(output, "\n", { trimempty = true })
      -- Convert to enhanced format
      local items = {}
      for _, file in ipairs(files) do
        table.insert(items, {
          name = file,
          type = "file",
          path = file
        })
      end
      callback(true, items)
    else
      callback(false, output)
    end
  end)
end

function LocalProvider:get_cwd(callback)
  callback(true, vim.fn.getcwd())
end

function LocalProvider:change_dir(path, callback)
  local success, err = pcall(vim.cmd.cd, path)
  if success then
    callback(true, "Changed directory to " .. path)
  else
    callback(false, "Failed to change directory: " .. err)
  end
end

function LocalProvider:delete_file(path, callback)
  local success, err = pcall(vim.fn.delete, path)
  if success and err == 0 then
    callback(true, "File deleted successfully")
  else
    callback(false, "Failed to delete file: " .. (err or "unknown error"))
  end
end

function LocalProvider:create_dir(path, callback)
  local success, err = pcall(vim.fn.mkdir, path, "p")
  if success then
    callback(true, "Directory created successfully")
  else
    callback(false, "Failed to create directory: " .. err)
  end
end

-- ============================================================================
-- Command Interface Implementation
-- ============================================================================

function LocalProvider:execute_command(cmd, args, callback)
  -- Handle both old format (cmd as table) and new format (cmd + args)
  local command
  if type(cmd) == "table" then
    command = cmd
    callback = args  -- callback is second parameter in old format
  else
    command = {cmd}
    if args and type(args) == "table" then
      vim.list_extend(command, args)
    end
  end
  
  Utils.run_async_command(command, function(stdout)
    callback(true, stdout)
  end, function(stderr, code)
    callback(false, stderr)
  end)
end

function LocalProvider:execute_async(cmd, args, callback)
  -- For local provider, async is same as regular execute
  -- Returns immediately with job_id
  local job_id = "local_" .. os.time() .. "_" .. math.random(1000)
  
  self:execute_command(cmd, args, function(success, result)
    -- Store result for later retrieval
    self.active_jobs[job_id] = {
      status = success and "completed" or "failed",
      result = result,
      exit_code = success and 0 or 1,
      end_time = os.time()
    }
  end)
  
  callback(true, job_id)
end

function LocalProvider:execute_shell(command_string, callback)
  -- Execute shell command string
  self:execute_command({"sh", "-c", command_string}, callback)
end

function LocalProvider:get_job_status(job_id)
  return self.active_jobs[job_id] or {
    status = "unknown",
    exit_code = -1
  }
end

function LocalProvider:get_command_history()
  return self.command_history or {}
end

function LocalProvider:get_shell_info()
  return {
    shell = vim.env.SHELL or "/bin/sh",
    working_dir = vim.fn.getcwd(),
    environment = vim.env
  }
end

return LocalProvider

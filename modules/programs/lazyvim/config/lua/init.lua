-- orbital-demo.lua
-- Minimal Virtual Buffer Layer Demo
-- Place this file in your Neovim config and source it

local M = {}

-- Global state for the demo
M.remote_buffers = {}
M.connection = {
  user = nil,
  host = nil,
  base_path = nil,
  connected = false,
}

-- Simple logging function
local function log(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[Orbital Demo] " .. msg, level)
end

-- Async job runner using vim.fn.jobstart
local function run_async_command(cmd, on_success, on_error)
  local stdout_data = {}
  local stderr_data = {}

  local job_id = vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(stdout_data, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(stderr_data, data)
      end
    end,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if exit_code == 0 then
          local stdout = table.concat(stdout_data, "\n")
          if on_success then
            on_success(stdout)
          end
        else
          local stderr = table.concat(stderr_data, "\n")
          if on_error then
            on_error(stderr, exit_code)
          end
        end
      end)
    end,
  })

  return job_id
end

-- Create a temporary file for SCP operations
local function create_temp_file()
  return vim.fn.tempname()
end

-- Read file content
local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil, "Cannot open file: " .. path
  end

  local content = file:read("*all")
  file:close()
  return content
end

-- Write file content
local function write_file(path, content)
  local file = io.open(path, "w")
  if not file then
    return false, "Cannot write file: " .. path
  end

  file:write(content)
  file:close()
  return true
end

-- Test SSH connection (async)
local function test_connection_async(user, host, callback)
  log("Testing connection to " .. user .. "@" .. host .. "...")

  local test_cmd = { "ssh", "-o", "ConnectTimeout=5", user .. "@" .. host, "echo orbital_connection_test" }

  run_async_command(test_cmd, function(stdout)
    if stdout:match("orbital_connection_test") then
      log("✓ Connection successful!")
      callback(true)
    else
      log("✗ Connection failed: unexpected output", vim.log.levels.ERROR)
      callback(false)
    end
  end, function(stderr, exit_code)
    log("✗ Connection failed: " .. (stderr or "timeout"), vim.log.levels.ERROR)
    callback(false)
  end)
end

-- Remote file operations
local RemoteFile = {}
RemoteFile.__index = RemoteFile

function RemoteFile.new(remote_path)
  local self = setmetatable({}, RemoteFile)

  self.remote_path = remote_path
  self.bufnr = nil
  self.original_content = {}
  self.is_dirty = false
  self.is_loading = false

  return self
end

function RemoteFile:load_from_remote()
  if self.is_loading then
    return false, "Already loading"
  end

  if not M.connection.connected then
    return false, "Not connected to remote"
  end

  self.is_loading = true

  -- Create buffer immediately for responsive UI
  self.bufnr = vim.api.nvim_create_buf(true, false) -- listed=true for bufferline

  -- Set buffer name and initial properties
  vim.api.nvim_buf_set_name(self.bufnr, "[Loading...] " .. vim.fn.fnamemodify(self.remote_path, ":t"))
  vim.api.nvim_buf_set_option(self.bufnr, "buftype", "nowrite") -- Prevent writes during load

  -- Set loading placeholder content (buffer is modifiable by default)
  local loading_content = {
    "📡 Loading " .. self.remote_path .. "...",
    "",
    "Please wait while the file is downloaded from the remote server.",
    "",
    "This is a placeholder that will be replaced with the actual content.",
  }
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, loading_content)

  -- Now make it non-modifiable to prevent editing during load
  vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)

  -- Switch to the buffer immediately
  vim.api.nvim_set_current_buf(self.bufnr)

  log("📡 Loading " .. self.remote_path .. " from remote...")

  -- Create temp file for SCP
  local temp_file = create_temp_file()
  local scp_cmd = { "scp", M.connection.user .. "@" .. M.connection.host .. ":" .. self.remote_path, temp_file }

  local start_time = vim.loop.hrtime()

  run_async_command(scp_cmd, function(stdout)
    -- Success callback
    local duration = (vim.loop.hrtime() - start_time) / 1e6

    -- Read the downloaded content
    local content, err = read_file(temp_file)
    os.remove(temp_file)

    if not content then
      self:handle_load_error("Failed to read downloaded file: " .. (err or "unknown"))
      return
    end

    -- Update buffer with actual content
    self.original_content = vim.split(content, "\n", { trimempty = false })

    -- Make buffer modifiable and update content
    vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, self.original_content)

    -- Set final buffer properties
    vim.api.nvim_buf_set_name(self.bufnr, "[Remote] " .. vim.fn.fnamemodify(self.remote_path, ":t"))
    vim.api.nvim_buf_set_option(self.bufnr, "buftype", "") -- Normal buffer
    vim.api.nvim_buf_set_option(self.bufnr, "modified", false)

    -- Detect and set filetype
    local filetype = vim.filetype.match({ filename = self.remote_path })
    if filetype then
      vim.api.nvim_buf_set_option(self.bufnr, "filetype", filetype)
    end

    -- Set up change tracking
    self:setup_change_tracking()

    self.is_loading = false
    log("✓ Loaded " .. self.remote_path .. " (took " .. math.floor(duration) .. "ms)")
  end, function(stderr, exit_code)
    -- Error callback
    os.remove(temp_file)
    self:handle_load_error("SCP failed: " .. (stderr or "unknown error"))
  end)

  return true -- Return true immediately since we're async
end

function RemoteFile:handle_load_error(error_msg)
  self.is_loading = false

  -- Update buffer to show error
  local error_content = {
    "❌ Failed to load " .. self.remote_path,
    "",
    "Error: " .. error_msg,
    "",
    "You can:",
    "1. Check your connection with :OrbitalStatus",
    "2. Try opening the file again",
    "3. Verify the file exists on the remote server",
  }

  vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, error_content)
  vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
  vim.api.nvim_buf_set_name(self.bufnr, "[Error] " .. vim.fn.fnamemodify(self.remote_path, ":t"))

  log("Failed to load " .. self.remote_path .. ": " .. error_msg, vim.log.levels.ERROR)
end

function RemoteFile:save_to_remote()
  if not self.is_dirty then
    log("No changes to save")
    return true
  end

  if not M.connection.connected then
    log("Not connected to remote", vim.log.levels.ERROR)
    return false
  end

  if self.is_loading then
    log("File is still loading, please wait", vim.log.levels.WARN)
    return false
  end

  -- Show saving indicator in buffer name
  local original_name = vim.api.nvim_buf_get_name(self.bufnr)
  vim.api.nvim_buf_set_name(self.bufnr, "[Saving...] " .. vim.fn.fnamemodify(self.remote_path, ":t"))

  -- Show progress in status
  log("💾 Saving " .. self.remote_path .. " to remote...")

  -- Get current buffer content
  local lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Write to temp file
  local temp_file = create_temp_file()
  local success, err = write_file(temp_file, content)

  if not success then
    vim.api.nvim_buf_set_name(self.bufnr, original_name)
    log("Failed to create temp file: " .. err, vim.log.levels.ERROR)
    return false
  end

  -- SCP to remote (async)
  local scp_cmd = { "scp", temp_file, M.connection.user .. "@" .. M.connection.host .. ":" .. self.remote_path }
  local start_time = vim.loop.hrtime()

  run_async_command(scp_cmd, function(stdout)
    -- Success callback
    local duration = (vim.loop.hrtime() - start_time) / 1e6
    os.remove(temp_file)

    -- Update state
    self.is_dirty = false
    self.original_content = lines
    vim.api.nvim_buf_set_option(self.bufnr, "modified", false)

    -- Restore buffer name
    vim.api.nvim_buf_set_name(self.bufnr, "[Remote] " .. vim.fn.fnamemodify(self.remote_path, ":t"))

    log("✓ Saved " .. self.remote_path .. " (took " .. math.floor(duration) .. "ms)")
  end, function(stderr, exit_code)
    -- Error callback
    os.remove(temp_file)
    vim.api.nvim_buf_set_name(self.bufnr, original_name)
    log("Failed to save " .. self.remote_path .. ": " .. (stderr or "unknown error"), vim.log.levels.ERROR)
  end)

  return true -- Return immediately, actual save is async
end

function RemoteFile:setup_change_tracking()
  -- Track changes to mark buffer as dirty
  vim.api.nvim_buf_attach(self.bufnr, false, {
    on_lines = function()
      if not self.is_loading then
        self.is_dirty = true
        vim.api.nvim_buf_set_option(self.bufnr, "modified", true)
        -- Update statusline indicator
        vim.cmd("redrawstatus")
      end
    end,
  })
end

function RemoteFile:show_status()
  local status = {
    "Remote File Status:",
    "  Path: " .. self.remote_path,
    "  Buffer: " .. (self.bufnr or "none"),
    "  Dirty: " .. tostring(self.is_dirty),
    "  Loading: " .. tostring(self.is_loading),
  }

  log(table.concat(status, "\n"))
end

-- Main plugin functions
function M.connect(connection_string)
  -- Parse user@host:/path format
  local user, host, path = connection_string:match("([^@]+)@([^:]+):(.+)")

  if not user or not host or not path then
    log("Invalid format. Use: user@host:/path", vim.log.levels.ERROR)
    return false
  end

  -- Test connection asynchronously
  test_connection_async(user, host, function(success)
    if success then
      -- Store connection info
      M.connection.user = user
      M.connection.host = host
      M.connection.base_path = path
      M.connection.connected = true

      log("🚀 Connected to " .. user .. "@" .. host .. " (base: " .. path .. ")")
    end
  end)

  return true -- Return immediately, connection test is async
end

function M.open_remote_file(relative_path)
  if not M.connection.connected then
    log("Not connected. Use :OrbitalConnect first", vim.log.levels.ERROR)
    return
  end

  local full_path = M.connection.base_path .. "/" .. relative_path

  -- Check if already open
  for _, remote_file in pairs(M.remote_buffers) do
    if remote_file.remote_path == full_path then
      vim.api.nvim_set_current_buf(remote_file.bufnr)
      log("File already open, switching to buffer")
      return
    end
  end

  -- Create and load new remote file
  local remote_file = RemoteFile.new(full_path)
  local success, err = remote_file:load_from_remote()

  if success then
    M.remote_buffers[remote_file.bufnr] = remote_file
    log("📂 Opening " .. relative_path .. "...")
    -- Buffer is already set as current in load_from_remote
  else
    log("Failed to open " .. relative_path .. ": " .. err, vim.log.levels.ERROR)
  end
end

function M.save_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local remote_file = M.remote_buffers[bufnr]

  if not remote_file then
    log("Current buffer is not a remote file", vim.log.levels.WARN)
    return
  end

  local success, err = remote_file:save_to_remote()
  if not success then
    log("Save failed: " .. err, vim.log.levels.ERROR)
  end
end

function M.status()
  if not M.connection.connected then
    log("Not connected")
    return
  end

  log("Connection: " .. M.connection.user .. "@" .. M.connection.host)
  log("Base path: " .. M.connection.base_path)
  log("Open files: " .. vim.tbl_count(M.remote_buffers))

  for bufnr, remote_file in pairs(M.remote_buffers) do
    log("  " .. remote_file.remote_path .. " (dirty: " .. tostring(remote_file.is_dirty) .. ")")
  end
end

function M.disconnect()
  M.connection = {
    user = nil,
    host = nil,
    base_path = nil,
    connected = false,
  }

  -- Keep buffers open but mark as disconnected
  for bufnr, remote_file in pairs(M.remote_buffers) do
    vim.api.nvim_buf_set_name(bufnr, "[Disconnected] " .. remote_file.remote_path)
  end

  log("Disconnected from remote")
end

-- Set up autocommands
local function setup_autocommands()
  local group = vim.api.nvim_create_augroup("OrbitalDemo", { clear = true })

  -- Universal file save handler - intercepts ALL buffer writes
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    callback = function(args)
      local remote_file = M.remote_buffers[args.buf]

      if remote_file then
        -- Handle remote file with our custom async logic
        remote_file:save_to_remote()
      else
        -- Handle local file with direct file write
        M.save_local_buffer(args.buf)
      end
    end,
  })

  -- Cleanup on buffer delete
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      M.remote_buffers[args.buf] = nil
    end,
  })
end

-- Save local buffer using vim.fn.writefile
function M.save_local_buffer(bufnr)
  -- Get buffer info
  local buffer_name = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Check if buffer has a valid file path
  if buffer_name == "" then
    log("Buffer has no filename. Use :w filename to save.", vim.log.levels.ERROR)
    return false
  end

  -- Skip special buffers (help, quickfix, etc.)
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  if buftype ~= "" then
    log("Cannot save special buffer type: " .. buftype, vim.log.levels.WARN)
    return false
  end

  log("💾 Saving local file: " .. buffer_name)

  -- Write file directly using vim.fn.writefile
  local success = pcall(vim.fn.writefile, lines, buffer_name)

  if success then
    -- Mark buffer as not modified
    vim.api.nvim_buf_set_option(bufnr, "modified", false)
    log("✓ Saved local file: " .. vim.fn.fnamemodify(buffer_name, ":t"))
    return true
  else
    log("Failed to save local file: " .. buffer_name, vim.log.levels.ERROR)
    return false
  end
end

-- Set up user commands
local function setup_commands()
  vim.api.nvim_create_user_command("OrbitalConnect", function(args)
    M.connect(args.args)
  end, {
    nargs = 1,
    desc = "Connect to remote host (user@host:/path)",
  })

  vim.api.nvim_create_user_command("OrbitalOpen", function(args)
    M.open_remote_file(args.args)
  end, {
    nargs = 1,
    desc = "Open remote file (relative to base path)",
  })

  vim.api.nvim_create_user_command("OrbitalStatus", function()
    M.status()
  end, {
    desc = "Show connection and file status",
  })

  vim.api.nvim_create_user_command("OrbitalSave", function()
    M.save_current_buffer()
  end, {
    desc = "Save current remote file",
  })

  vim.api.nvim_create_user_command("OrbitalDisconnect", function()
    M.disconnect()
  end, {
    desc = "Disconnect from remote host",
  })
end

-- Initialize the demo
function M.setup()
  setup_autocommands()
  setup_commands()

  log("🚀 Orbital Demo initialized!")
  log("Usage:")
  log("  :OrbitalConnect user@host:/path")
  log("  :OrbitalOpen relative/file/path")
  log("  :w (or :OrbitalSave) to save")
  log("  :OrbitalStatus to check status")
end

-- Auto-setup when required
M.setup()

return M


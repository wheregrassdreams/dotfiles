-- orbital/client/command_interceptor/handlers.lua
-- Interface-Based Command Handling Logic

local M = {}

-- State for tracking intercepted commands
M.intercepted_commands = {}

-- Logging function
local function log(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[Orbital] " .. msg, level)
end

-- ============================================================================
-- Interface-Based Operation Validation
-- ============================================================================

local function validate_operation(backend_manager, operation)
  if not backend_manager.current_provider then
    log("No active provider, using default behavior", vim.log.levels.WARN)
    return false, "No active provider"
  end
  
  local can_handle, error_msg = backend_manager.can_handle_operation(operation)
  if not can_handle then
    log("Provider cannot handle " .. operation .. ": " .. error_msg, vim.log.levels.WARN)
    return false, error_msg
  end
  
  return true, nil
end

-- ============================================================================
-- File Operations
-- ============================================================================

function M.handle_edit_command(backend_manager, args)
  local can_handle, error_msg = validate_operation(backend_manager, "read_file")
  if not can_handle then
    return false
  end
  
  local current_provider = backend_manager.current_provider

  if not args or args == "" then
    log("No filename specified", vim.log.levels.ERROR)
    return true
  end

  -- Check if buffer for this file already exists
  local buffer_name = "[" .. current_provider.type .. "] " .. args
  local existing_bufnr = vim.fn.bufnr(buffer_name)

  if existing_bufnr ~= -1 and vim.api.nvim_buf_is_valid(existing_bufnr) then
    -- Buffer already exists, check if it has unsaved changes
    local is_modified = vim.api.nvim_buf_get_option(existing_bufnr, "modified")

    if is_modified then
      -- Ask user what to do with unsaved changes
      local choice = vim.fn.confirm(
        "Buffer has unsaved changes. What do you want to do?",
        "&Reload from backend\n&Keep local changes\n&Cancel",
        2
      )

      if choice == 1 then
        -- Reload from backend
        M.reload_buffer_from_provider(current_provider, existing_bufnr, args)
      elseif choice == 2 then
        -- Keep local changes, just switch to buffer
        vim.api.nvim_set_current_buf(existing_bufnr)
        log("Switched to existing buffer with local changes")
      end
      -- choice == 3 or 0 means cancel, do nothing
    else
      -- No unsaved changes, reload from backend
      M.reload_buffer_from_provider(current_provider, existing_bufnr, args)
    end

    return true
  end

  log("📂 Opening file via " .. current_provider.type .. " backend: " .. args)

  -- Show loading indicator for potentially slow operations
  if current_provider.type == "ssh" then
    log("⏳ Loading file over SSH...")
  end

  -- Read file through current backend
  current_provider:read_file(args, function(success, content)
    local bufnr = vim.api.nvim_create_buf(true, false)
    local lines = {}

    if success then
      -- File exists, use its content
      lines = vim.split(content, "\n", { trimempty = false })
      log("✓ Loaded existing file " .. args .. " via " .. current_provider.type .. " backend")
    else
      -- File doesn't exist, create new empty buffer
      lines = { "" }
      log("✓ Created new file " .. args .. " via " .. current_provider.type .. " backend")
    end

    -- Set buffer content
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(bufnr, buffer_name)
    vim.api.nvim_buf_set_option(bufnr, "modified", false)

    -- Detect and set filetype
    local filetype = vim.filetype.match({ filename = args })
    if filetype then
      vim.api.nvim_buf_set_option(bufnr, "filetype", filetype)
    end

    -- Switch to buffer
    vim.api.nvim_set_current_buf(bufnr)

    -- Store backend info for this buffer
    M.intercepted_commands[bufnr] = {
      provider = current_provider,
      filename = args,
      is_new_file = not success,
      load_time = vim.loop.hrtime(),
    }
  end)

  return true
end

function M.reload_buffer_from_provider(provider, bufnr, filename)
  log("🔄 Reloading " .. filename .. " from " .. provider.type .. " backend...")

  local start_time = vim.loop.hrtime()

  provider:read_file(filename, function(success, content)
    if success then
      local lines = vim.split(content, "\n", { trimempty = false })
      local load_time = (vim.loop.hrtime() - start_time) / 1e6

      -- Update buffer content
      vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(bufnr, "modified", false)

      -- Switch to buffer
      vim.api.nvim_set_current_buf(bufnr)

      log(string.format("✓ Reloaded %s from backend (%.1fms)", filename, load_time))
    else
      log("Failed to reload " .. filename .. ": " .. content, vim.log.levels.ERROR)
    end
  end)
end

function M.handle_write_command(backend_manager, args)
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_info = M.intercepted_commands[bufnr]

  if buffer_info then
    -- This is a provider-managed buffer - validate write capability
    local can_handle, error_msg = buffer_info.provider:can_handle("write_file")
    if not can_handle then
      log("Provider cannot write file: " .. error_msg, vim.log.levels.ERROR)
      return false
    end

    -- Proceed with write operation
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")

    log("💾 Saving file via " .. buffer_info.provider.type .. " provider: " .. buffer_info.filename)

    local start_time = vim.loop.hrtime()

    buffer_info.provider:write_file(buffer_info.filename, content, function(success, message)
      if success then
        local save_time = (vim.loop.hrtime() - start_time) / 1e6
        vim.api.nvim_buf_set_option(bufnr, "modified", false)
        log(string.format("✓ Saved %s (%.1fms)", buffer_info.filename, save_time))
      else
        log("Failed to save " .. buffer_info.filename .. ": " .. message, vim.log.levels.ERROR)
      end
    end)

    return true -- Handled by backend
  end

  return false -- Let default behavior handle it
end

function M.handle_write_all_command(backend_manager, args)
  local handled_any = false
  local save_count = 0

  -- Iterate through all buffers and save backend-managed ones
  for bufnr, buffer_info in pairs(M.intercepted_commands) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_option(bufnr, "modified") then
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local content = table.concat(lines, "\n")

      save_count = save_count + 1

      buffer_info.provider:write_file(buffer_info.filename, content, function(success, message)
        if success then
          vim.api.nvim_buf_set_option(bufnr, "modified", false)
          log("✓ Saved " .. buffer_info.filename)
        else
          log("Failed to save " .. buffer_info.filename .. ": " .. message, vim.log.levels.ERROR)
        end
      end)

      handled_any = true
    end
  end

  if handled_any then
    log("💾 Saving " .. save_count .. " files via backend...")
  end

  return handled_any
end

-- ============================================================================
-- Directory Operations
-- ============================================================================

function M.handle_cd_command(backend_manager, args)
  local can_handle, error_msg = validate_operation(backend_manager, "change_dir")
  if not can_handle then
    return false
  end

  if not args or args == "" then
    log("No directory specified", vim.log.levels.ERROR)
    return true
  end

  local current_provider = backend_manager.current_provider
  current_provider:change_dir(args, function(success, message)
    if success then
      log("✓ " .. message)
      -- Trigger event for Neo-tree refresh
      vim.api.nvim_exec_autocmds("User", {
        pattern = "OrbitalDirectoryChanged",
        data = { provider = current_provider, path = args },
      })
    else
      log("Failed to change directory: " .. message, vim.log.levels.ERROR)
    end
  end)

  return true
end

function M.handle_pwd_command(backend_manager, args)
  local can_handle, error_msg = validate_operation(backend_manager, "get_cwd")
  if not can_handle then
    return false
  end

  local current_provider = backend_manager.current_provider
  current_provider:get_cwd(function(success, path)
    if success then
      log("Current directory (" .. current_provider.type .. "): " .. path)
    else
      log("Failed to get current directory: " .. path, vim.log.levels.ERROR)
    end
  end)

  return true
end

function M.handle_ls_command(backend_manager, args)
  local can_handle, error_msg = validate_operation(backend_manager, "list_files")
  if not can_handle then
    return false
  end

  local path = args and args ~= "" and args or "."
  local current_provider = backend_manager.current_provider

  current_provider:list_files(path, function(success, items)
    if success then
      log("Files in " .. path .. " (" .. current_provider.type .. " provider):")

      if type(items[1]) == "table" then
        -- Enhanced format with item objects
        for _, item in ipairs(items) do
          local icon = item.type == "directory" and "📁" or item.type == "link" and "🔗" or "📄"
          print("  " .. icon .. " " .. item.name)
        end
      else
        -- Legacy format with simple strings
        for _, file in ipairs(items) do
          print("  📄 " .. file)
        end
      end
    else
      log("Failed to list files: " .. items, vim.log.levels.ERROR)
    end
  end)

  return true
end

-- ============================================================================
-- Compound Commands
-- ============================================================================

function M.handle_wq_command(backend_manager, args)
  local write_handled = M.handle_write_command(backend_manager, args)
  if write_handled then
    vim.schedule(function()
      vim.cmd.quit()
    end)
    return true
  end
  return false
end

-- ============================================================================
-- Buffer Management
-- ============================================================================

function M.cleanup_buffer(bufnr)
  M.intercepted_commands[bufnr] = nil
end

function M.get_managed_buffer_count()
  return vim.tbl_count(M.intercepted_commands)
end

function M.get_buffer_info(bufnr)
  return M.intercepted_commands[bufnr]
end


return M

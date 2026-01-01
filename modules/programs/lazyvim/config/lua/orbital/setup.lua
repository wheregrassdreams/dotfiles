-- orbital/setup.lua
-- Setup and Configuration Logic

local M = {}

-- Logging function
local function log(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[Orbital] " .. msg, level)
end

-- ============================================================================
-- User Commands Setup
-- ============================================================================

function M.setup_commands(backend_manager, command_handlers)
  -- Backend management commands
  vim.api.nvim_create_user_command("OrbitalBackend", function(args)
    backend_manager.switch_provider(args.args)
  end, {
    nargs = 1,
    desc = "Switch to backend (file://, ssh://user@host/path, nvim://user@host/path, etc.)",
    complete = function(arg_lead, cmd_line, cursor_pos)
      return backend_manager.get_provider_completions(arg_lead)
    end,
  })

  vim.api.nvim_create_user_command("OrbitalStatus", function()
    local status = backend_manager.get_status()
    
    if status.current_provider then
      log("Current backend: " .. status.provider_info.uri .. " (" .. status.provider_info.type .. ")")
      log("Connected: " .. tostring(status.provider_info.connected))
      log("Managed buffers: " .. command_handlers.get_managed_buffer_count())

      -- Show RPC-specific status
      if status.rpc_info then
        log("Server status: " .. status.rpc_info.server_status)
        log("Health monitoring: " .. tostring(status.rpc_info.health_monitoring))
        if status.rpc_info.reconnect_attempts > 0 then
          log("Reconnect attempts: " .. status.rpc_info.reconnect_attempts .. "/" .. status.rpc_info.max_reconnect_attempts)
        end

        -- Get server stats if connected
        if status.provider_info.connected then
          status.current_provider:send_rpc_request("server.stats", {}, function(success, stats)
            if success then
              log("Server uptime: " .. (stats.uptime or 0) .. "s")
              log("Requests handled: " .. (stats.stats.requests_handled or 0))
              log("Memory usage: " .. (stats.memory_usage or "unknown"))
            end
          end)
        end
      end
    else
      log("No active backend")
    end
  end, { desc = "Show current backend status" })

  vim.api.nvim_create_user_command("OrbitalList", function(args)
    local current_provider = backend_manager.current_provider
    
    if not current_provider or not current_provider.connected then
      log("No active backend", vim.log.levels.ERROR)
      return
    end

    local path = args.args and args.args ~= "" and args.args or "."
    local start_time = vim.loop.hrtime()

    current_provider:list_files(path, function(success, items)
      if success then
        local list_time = (vim.loop.hrtime() - start_time) / 1e6
        log(string.format("Files in %s (%s, %.1fms):", path, current_provider.type, list_time))

        if type(items[1]) == "table" then
          -- Enhanced format with file info
          for _, item in ipairs(items) do
            local icon = item.type == "directory" and "📁" or item.type == "link" and "🔗" or "📄"
            print("  " .. icon .. " " .. item.name)
          end
        else
          -- Simple format
          for _, file in ipairs(items) do
            print("  " .. file)
          end
        end
      else
        log("Failed to list files: " .. items, vim.log.levels.ERROR)
      end
    end)
  end, {
    nargs = "?",
    desc = "List files in current backend (optional path)",
  })

  -- Performance testing command
  vim.api.nvim_create_user_command("OrbitalPerformanceTest", function()
    local current_provider = backend_manager.current_provider
    
    if not current_provider or not current_provider.connected then
      log("No active backend", vim.log.levels.ERROR)
      return
    end

    log("🚀 Running performance test on " .. current_provider.type .. " backend...")

    -- Test file read
    local test_file = "orbital_perf_test.txt"
    local test_content = string.rep("Performance test line\n", 100)

    local write_start = vim.loop.hrtime()
    current_provider:write_file(test_file, test_content, function(success, message)
      if success then
        local write_time = (vim.loop.hrtime() - write_start) / 1e6
        log(string.format("📝 Write test: %.1fms", write_time))

        local read_start = vim.loop.hrtime()
        current_provider:read_file(test_file, function(success, content)
          if success then
            local read_time = (vim.loop.hrtime() - read_start) / 1e6
            log(string.format("📖 Read test: %.1fms", read_time))
            log(string.format("📊 Total round-trip: %.1fms", write_time + read_time))
          else
            log("❌ Read test failed: " .. content, vim.log.levels.ERROR)
          end
        end)
      else
        log("❌ Write test failed: " .. message, vim.log.levels.ERROR)
      end
    end)
  end, { desc = "Run performance test on current backend" })

  -- Neo-tree integration commands
  vim.api.nvim_create_user_command("OrbitalNeotree", function()
    vim.cmd("Neotree source=orbital_backend")
  end, { desc = "Open Neo-tree with backend source" })

  vim.api.nvim_create_user_command("OrbitalNeotreeToggle", function()
    vim.cmd("Neotree toggle source=orbital_backend")
  end, { desc = "Toggle Neo-tree with backend source" })
end

-- ============================================================================
-- RPC-Specific Commands
-- ============================================================================

function M.setup_rpc_commands(backend_manager)
  -- Check if RPC provider is available
  local has_rpc = false
  pcall(function()
    require("orbital.providers.neovim_rpc_provider")
    has_rpc = true
  end)

  if not has_rpc then
    return
  end

  vim.api.nvim_create_user_command("OrbitalRPCPing", function()
    local current_provider = backend_manager.current_provider
    
    if not current_provider or current_provider.type ~= "neovim_rpc" then
      log("Current backend is not Neovim RPC", vim.log.levels.ERROR)
      return
    end

    if not current_provider.connected then
      log("RPC backend not connected", vim.log.levels.ERROR)
      return
    end

    local start_time = vim.loop.hrtime()
    current_provider:send_rpc_request("server.ping", {}, function(success, result)
      local ping_time = (vim.loop.hrtime() - start_time) / 1e6

      if success then
        log(string.format("✅ Pong! (%.1fms) - Server uptime: %ds", ping_time, result.uptime or 0))
      else
        log("❌ Ping failed: " .. tostring(result), vim.log.levels.ERROR)
      end
    end)
  end, { desc = "Ping Neovim RPC server" })

  vim.api.nvim_create_user_command("OrbitalRPCReconnect", function()
    local current_provider = backend_manager.current_provider
    
    if not current_provider or current_provider.type ~= "neovim_rpc" then
      log("Current backend is not Neovim RPC", vim.log.levels.ERROR)
      return
    end

    if backend_manager.server_manager then
      log("🔄 Attempting manual reconnection...")
      backend_manager.server_manager:attempt_reconnect()
    else
      log("No server manager available", vim.log.levels.ERROR)
    end
  end, { desc = "Manually reconnect to Neovim RPC server" })
end

-- ============================================================================
-- Autocommands Setup
-- ============================================================================

-- moved to `orbital/buffers/init.lua`

-- ============================================================================
-- Integration Setup
-- ============================================================================

function M.setup_integrations(backend_manager)
  -- Setup Neo-tree integration with error handling
  local neotree_integration = nil
  pcall(function()
    neotree_integration = require("orbital.integrations.neotree")
  end)

  if neotree_integration then
    local ok, err = pcall(neotree_integration.setup, {
      current_provider = backend_manager.current_provider,
      intercepted_commands = {}, -- We'll need to pass this from command_handlers
    })
    if not ok then
      log("Neo-tree integration setup failed: " .. tostring(err), vim.log.levels.WARN)
      neotree_integration = nil -- Disable integration if it fails
    else
      log("🌳 Neo-tree integration enabled!")
    end
  end

  return neotree_integration ~= nil
end

-- ============================================================================
-- Main Setup Function
-- ============================================================================

function M.setup_all(backend_manager, command_handlers, command_pipeline)
  -- Set up command pipeline with our handlers
  local handlers = command_handlers.create_handlers(backend_manager)
  command_pipeline.setup(handlers)

  -- Set up all user commands
  M.setup_commands(backend_manager, command_handlers)
  M.setup_rpc_commands(backend_manager)
  
  -- Set up autocommands
  M.setup_autocommands(command_handlers)
  
  -- Set up integrations
  local has_neotree = M.setup_integrations(backend_manager)

  -- Initialize backend manager
  backend_manager.initialize()

  -- Final setup messages
  log("🔧 Built-in command interception active!")
  log("📖 Usage:")
  log("  :OrbitalBackend file://")
  log("  :OrbitalBackend ssh://user@host/path")
  
  -- Check if RPC is available
  local has_rpc = false
  pcall(function()
    require("orbital.providers.neovim_rpc_provider")
    has_rpc = true
  end)
  
  if has_rpc then
    log("  :OrbitalBackend nvim://user@host/path  (High Performance)")
  end
  
  log("  :e filename (intercepted)")
  log("  :w (intercepted)")
  log("  :cd path (intercepted)")
  log("  :OrbitalStatus (show backend info)")
  log("  :OrbitalPerformanceTest (benchmark backend)")
  
  if has_rpc then
    log("  :OrbitalRPCPing (test RPC connection)")
  end
end

return M

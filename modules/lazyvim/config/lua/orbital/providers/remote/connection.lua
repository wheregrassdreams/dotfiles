-- orbital/client/providers/remote/connection.lua
-- Connection Management for Remote Provider

local Utils = require("orbital.utils")

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new(config)
  local self = setmetatable({}, ConnectionManager)

  -- Connection configuration
  self.host = config.host
  self.port = config.port or 6666
  self.user = config.user
  self.uri = config.uri

  -- Connection state
  self.rpc_client = nil
  self.connection_state = "disconnected"
  self.connected = false
  self.last_ping = nil
  self.connection_start_time = nil

  -- Reconnection management
  self.reconnect_attempts = 0
  self.max_reconnect_attempts = config.max_reconnect_attempts or 3
  self.reconnect_delay = config.reconnect_delay or 2000
  self.auto_reconnect = config.auto_reconnect ~= false

  -- Health monitoring
  self.ping_interval = config.ping_interval or 30000 -- 30 seconds
  self.ping_timeout = config.ping_timeout or 5000 -- 5 seconds
  self.health_check_timer = nil

  -- Connection events
  self.event_handlers = {
    connected = {},
    disconnected = {},
    reconnecting = {},
    health_check = {},
  }

  return self
end

-- ============================================================================
-- Core Connection Management
-- ============================================================================

function ConnectionManager:connect(callback)
  if self.connection_state == "connecting" then
    if callback then
      callback(false, "Already connecting")
    end
    return
  end

  self.connection_state = "connecting"
  self.connection_start_time = vim.loop.hrtime()

  Utils.log("🔗 Connecting to orbital server at " .. self.host .. ":" .. self.port)
  self:emit_event("connecting", { host = self.host, port = self.port })

  vim.schedule(function()
    local ok, client = pcall(vim.rpc.connect, self.host, self.port)

    if ok and client then
      self.rpc_client = client
      self.connection_state = "connected"
      self.connected = true
      self.reconnect_attempts = 0

      local connection_time = (vim.loop.hrtime() - self.connection_start_time) / 1e6
      Utils.log("✅ Connected to orbital server (" .. string.format("%.1fms", connection_time) .. ")")

      -- Start health monitoring
      if self.auto_reconnect then
        self:start_health_monitoring()
      end

      -- Emit connected event
      self:emit_event("connected", {
        connection_time = connection_time,
        attempt = self.reconnect_attempts,
      })

      -- Test connection with ping
      self:ping(function(ping_success, response_time)
        if ping_success then
          Utils.log("✅ Server ping successful (" .. response_time .. "ms)")
          if callback then
            callback(true, "Connected successfully")
          end
        else
          Utils.log("⚠️ Server ping failed, but connection established")
          if callback then
            callback(true, "Connected (ping failed)")
          end
        end
      end)
    else
      self.connection_state = "failed"
      self.connected = false

      local error_msg = "Connection failed: " .. tostring(client)
      Utils.log("❌ Failed to connect to orbital server: " .. tostring(client))

      self:emit_event("connection_failed", { error = error_msg, attempt = self.reconnect_attempts })

      if callback then
        callback(false, error_msg)
      end
    end
  end)
end

function ConnectionManager:disconnect(callback)
  -- Stop health monitoring
  self:stop_health_monitoring()

  if self.rpc_client then
    pcall(function()
      self.rpc_client:close()
    end)
    self.rpc_client = nil
  end

  local was_connected = self.connected
  self.connection_state = "disconnected"
  self.connected = false

  if was_connected then
    Utils.log("📡 Disconnected from orbital server")
    self:emit_event("disconnected", { voluntary = true })
  end

  if callback then
    callback(true, "Disconnected")
  end
end

function ConnectionManager:reconnect(callback)
  self.reconnect_attempts = self.reconnect_attempts + 1

  if self.reconnect_attempts > self.max_reconnect_attempts then
    Utils.log("❌ Max reconnection attempts reached")
    self:emit_event("reconnect_failed", { attempts = self.reconnect_attempts })
    if callback then
      callback(false, "Max reconnection attempts reached")
    end
    return
  end

  Utils.log("🔄 Attempting reconnection (" .. self.reconnect_attempts .. "/" .. self.max_reconnect_attempts .. ")")
  self:emit_event("reconnecting", { attempt = self.reconnect_attempts })

  self:disconnect()
  vim.defer_fn(function()
    self:connect(callback)
  end, self.reconnect_delay)
end

-- ============================================================================
-- Health Monitoring
-- ============================================================================

function ConnectionManager:start_health_monitoring()
  if self.health_check_timer then
    self:stop_health_monitoring()
  end

  self.health_check_timer = vim.loop.new_timer()
  self.health_check_timer:start(self.ping_interval, self.ping_interval, function()
    vim.schedule(function()
      if self:is_connected() then
        self:health_check()
      end
    end)
  end)
end

function ConnectionManager:stop_health_monitoring()
  if self.health_check_timer then
    self.health_check_timer:stop()
    self.health_check_timer:close()
    self.health_check_timer = nil
  end
end

function ConnectionManager:health_check()
  self:ping(function(success, response_time)
    local health_data = {
      success = success,
      response_time = response_time,
      timestamp = os.time(),
    }

    if success then
      self:emit_event("health_check", health_data)
    else
      Utils.log("🔍 Health check failed, attempting reconnect...")
      self:emit_event("health_check_failed", health_data)

      if self.auto_reconnect then
        self:reconnect()
      end
    end
  end)
end

function ConnectionManager:ping(callback)
  if not self:is_connected() then
    callback(false, "Not connected")
    return
  end

  local start_time = vim.loop.hrtime()

  -- Use a timeout for ping
  local timeout_timer = vim.loop.new_timer()
  local completed = false

  timeout_timer:start(self.ping_timeout, 0, function()
    if not completed then
      completed = true
      timeout_timer:close()
      vim.schedule(function()
        callback(false, "Ping timeout")
      end)
    end
  end)

  -- Send ping request
  local ok, result = pcall(function()
    return self.rpc_client:request("orbital.ping", {})
  end)

  if not completed then
    completed = true
    timeout_timer:close()

    local response_time = (vim.loop.hrtime() - start_time) / 1e6
    self.last_ping = os.time()

    if ok then
      callback(true, response_time)
    else
      callback(false, "Ping failed: " .. tostring(result))
    end
  end
end

-- ============================================================================
-- Connection State Management
-- ============================================================================

function ConnectionManager:is_connected()
  return self.connected and self.rpc_client ~= nil
end

function ConnectionManager:get_connection_state()
  return self.connection_state
end

function ConnectionManager:get_connection_info()
  return {
    host = self.host,
    port = self.port,
    user = self.user,
    uri = self.uri,
    state = self.connection_state,
    connected = self.connected,
    last_ping = self.last_ping,
    reconnect_attempts = self.reconnect_attempts,
    max_reconnect_attempts = self.max_reconnect_attempts,
    auto_reconnect = self.auto_reconnect,
    health_monitoring = self.health_check_timer ~= nil,
  }
end

function ConnectionManager:get_rpc_client()
  return self.rpc_client
end

-- ============================================================================
-- Event System
-- ============================================================================

function ConnectionManager:on(event, handler)
  if not self.event_handlers[event] then
    self.event_handlers[event] = {}
  end
  table.insert(self.event_handlers[event], handler)
end

function ConnectionManager:off(event, handler)
  if self.event_handlers[event] then
    for i, h in ipairs(self.event_handlers[event]) do
      if h == handler then
        table.remove(self.event_handlers[event], i)
        break
      end
    end
  end
end

function ConnectionManager:emit_event(event, data)
  if self.event_handlers[event] then
    for _, handler in ipairs(self.event_handlers[event]) do
      pcall(handler, data)
    end
  end
end

-- ============================================================================
-- Configuration Management
-- ============================================================================

function ConnectionManager:update_config(config)
  -- Update reconnection settings
  if config.max_reconnect_attempts then
    self.max_reconnect_attempts = config.max_reconnect_attempts
  end

  if config.reconnect_delay then
    self.reconnect_delay = config.reconnect_delay
  end

  if config.auto_reconnect ~= nil then
    self.auto_reconnect = config.auto_reconnect

    if self.auto_reconnect and self:is_connected() then
      self:start_health_monitoring()
    elseif not self.auto_reconnect then
      self:stop_health_monitoring()
    end
  end

  -- Update ping settings
  if config.ping_interval then
    self.ping_interval = config.ping_interval

    if self.health_check_timer then
      self:stop_health_monitoring()
      self:start_health_monitoring()
    end
  end
end

-- ============================================================================
-- Cleanup
-- ============================================================================

function ConnectionManager:cleanup()
  self:stop_health_monitoring()
  self:disconnect()
  self.event_handlers = {}
end

return ConnectionManager


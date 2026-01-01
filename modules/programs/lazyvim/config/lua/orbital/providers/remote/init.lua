-- orbital/client/providers/remote/init.lua
-- Remote Provider Implementation (All interfaces via Neovim RPC)
-- Composition-based architecture using specialized modules

local Provider = require("orbital.client.providers.provider")
local Utils = require("orbital.utils")

-- Import interfaces
local FileSystemInterface = require("orbital.interfaces.filesystem")
local ConnectionInterface = require("orbital.interfaces.connection")
local CommandInterface = require("orbital.interfaces.command")
local LSPInterface = require("orbital.interfaces.lsp")

-- Import specialized modules
local ConnectionManager = require("orbital.client.providers.remote.connection")
local RPCClient = require("orbital.client.providers.remote.rpc")
local FilesystemOps = require("orbital.client.providers.remote.filesystem")
local CommandOps = require("orbital.client.providers.remote.commands")
local CacheManager = require("orbital.client.providers.remote.cache")

local RemoteProvider = setmetatable({}, { __index = Provider })
RemoteProvider.__index = RemoteProvider

function RemoteProvider.new(uri)
  local self = setmetatable(Provider.new(uri), RemoteProvider)
  self.type = "remote"

  -- Parse URI: orbital://user@host:port/path
  local host, port, user, path = self:parse_uri(uri)
  self.host = host
  self.port = port or 6666
  self.user = user
  self.base_path = path or "/"

  -- Register all supported interfaces
  self:add_interface("filesystem", FileSystemInterface)
  self:add_interface("connection", ConnectionInterface)
  self:add_interface("command", CommandInterface)
  self:add_interface("lsp", LSPInterface)

  -- Initialize specialized modules
  self:init_modules()

  return self
end

-- ============================================================================
-- Module Initialization
-- ============================================================================

function RemoteProvider:init_modules()
  -- Initialize cache manager
  self.cache_manager = CacheManager.new({
    max_size = 500,
    default_ttl = 300000,  -- 5 minutes
    max_memory_mb = 50,
    eviction_policy = "lru"
  })
  
  -- Initialize connection manager
  self.connection_manager = ConnectionManager.new({
    host = self.host,
    port = self.port,
    user = self.user,
    uri = self.uri,
    max_reconnect_attempts = 3,
    reconnect_delay = 2000,
    auto_reconnect = true,
    ping_interval = 30000,
    ping_timeout = 5000
  })
  
  -- Initialize RPC client
  self.rpc_client = RPCClient.new(self.connection_manager)
  
  -- Initialize filesystem operations
  self.filesystem_ops = FilesystemOps.new(self.rpc_client, self.cache_manager)
  
  -- Initialize command operations
  self.command_ops = CommandOps.new(self.rpc_client)
  
  -- Set up event handlers
  self:setup_event_handlers()
end

function RemoteProvider:setup_event_handlers()
  -- Connection events
  self.connection_manager:on("connected", function(data)
    Utils.log("🎉 Remote provider connected: " .. self.host .. ":" .. self.port)
    self.connected = true
    self.connection_info.connected_at = os.time()
  end)
  
  self.connection_manager:on("disconnected", function(data)
    Utils.log("📡 Remote provider disconnected: " .. self.host .. ":" .. self.port)
    self.connected = false
  end)
  
  self.connection_manager:on("reconnecting", function(data)
    Utils.log("🔄 Remote provider reconnecting (attempt " .. data.attempt .. ")")
  end)
  
  self.connection_manager:on("health_check_failed", function(data)
    Utils.log("⚠️ Remote provider health check failed")
  end)
end

-- ============================================================================
-- URI Parsing
-- ============================================================================

function RemoteProvider:parse_uri(uri)
  -- Parse orbital://user@host:port/path
  local pattern = "^orbital://([^@]+)@([^:]+):?(%d*)(.*)$"
  local user, host, port, path = uri:match(pattern)

  if not user or not host then
    error("Invalid orbital URI. Expected format: orbital://user@host:port/path")
  end

  return host, tonumber(port), user, path ~= "" and path or "/"
end

-- ============================================================================
-- Connection Interface Implementation (Delegated to ConnectionManager)
-- ============================================================================

function RemoteProvider:connect(uri, callback)
  self.connection_manager:connect(callback)
end

function RemoteProvider:disconnect(callback)
  self.connection_manager:disconnect(callback)
end

function RemoteProvider:reconnect(callback)
  self.connection_manager:reconnect(callback)
end

function RemoteProvider:is_connected()
  return self.connection_manager:is_connected()
end

function RemoteProvider:get_connection_info()
  local base_info = self.connection_manager:get_connection_info()
  return vim.tbl_extend("force", base_info, {
    type = "remote",
    base_path = self.base_path,
    cache_stats = self.cache_manager:get_stats(),
    rpc_stats = self.rpc_client:get_stats(),
    filesystem_stats = self.filesystem_ops:get_cache_stats(),
    command_stats = self.command_ops:get_stats()
  })
end

function RemoteProvider:ping(callback)
  self.connection_manager:ping(callback)
end

function RemoteProvider:health_check()
  return self.connection_manager:health_check()
end

-- ============================================================================
-- RPC Communication (Delegated to RPCClient)
-- ============================================================================

function RemoteProvider:send_rpc_request(method, params, callback, options)
  return self.rpc_client:request(method, params, callback, options)
end

function RemoteProvider:send_rpc_notification(method, params)
  return self.rpc_client:notify(method, params)
end

-- ============================================================================
-- FileSystem Interface Implementation (Delegated to FilesystemOps)
-- ============================================================================

function RemoteProvider:read_file(path, callback, options)
  self.filesystem_ops:read_file(path, callback, options)
end

function RemoteProvider:write_file(path, content, callback, options)
  self.filesystem_ops:write_file(path, content, callback, options)
end

function RemoteProvider:list_files(path, callback, options)
  self.filesystem_ops:list_files(path, callback, options)
end

function RemoteProvider:get_cwd(callback)
  self.filesystem_ops:get_cwd(callback)
end

function RemoteProvider:change_dir(path, callback)
  self.filesystem_ops:change_dir(path, callback)
end

function RemoteProvider:delete_file(path, callback, options)
  self.filesystem_ops:delete_file(path, callback, options)
end

function RemoteProvider:copy_file(src, dest, callback, options)
  self.filesystem_ops:copy_file(src, dest, callback, options)
end

function RemoteProvider:move_file(src, dest, callback, options)
  self.filesystem_ops:move_file(src, dest, callback, options)
end

function RemoteProvider:create_dir(path, callback, options)
  self.filesystem_ops:create_dir(path, callback, options)
end

function RemoteProvider:delete_dir(path, callback, options)
  self.filesystem_ops:delete_dir(path, callback, options)
end

function RemoteProvider:get_file_info(path, callback, options)
  self.filesystem_ops:get_file_info(path, callback, options)
end

function RemoteProvider:watch_file(path, callback, options)
  return self.filesystem_ops:watch_file(path, callback, options)
end

function RemoteProvider:unwatch_file(watch_id, callback)
  self.filesystem_ops:unwatch_file(watch_id, callback)
end

-- Batch operations
function RemoteProvider:batch_read_files(paths, callback, options)
  self.filesystem_ops:batch_read_files(paths, callback, options)
end

function RemoteProvider:batch_write_files(file_operations, callback, options)
  self.filesystem_ops:batch_write_files(file_operations, callback, options)
end

-- ============================================================================
-- Command Interface Implementation (Delegated to CommandOps)
-- ============================================================================

function RemoteProvider:execute_command(cmd, args, callback, options)
  self.command_ops:execute_command(cmd, args, callback, options)
end

function RemoteProvider:execute_async(cmd, args, callback, options)
  self.command_ops:execute_async(cmd, args, callback, options)
end

function RemoteProvider:execute_shell(command_string, callback, options)
  self.command_ops:execute_shell(command_string, callback, options)
end

function RemoteProvider:get_job_status(job_id, callback)
  if callback then
    self.command_ops:get_job_status(job_id, callback)
  else
    return self.command_ops:get_job_status(job_id)
  end
end

function RemoteProvider:cancel_job(job_id, callback)
  self.command_ops:cancel_job(job_id, callback)
end

function RemoteProvider:wait_for_job(job_id, callback, timeout)
  self.command_ops:wait_for_job(job_id, callback, timeout)
end

function RemoteProvider:list_active_jobs()
  return self.command_ops:list_active_jobs()
end

function RemoteProvider:get_command_history(limit)
  return self.command_ops:get_command_history(limit)
end

function RemoteProvider:get_job_history(limit)
  return self.command_ops:get_job_history(limit)
end

function RemoteProvider:clear_history()
  self.command_ops:clear_history()
end

function RemoteProvider:get_shell_info(callback)
  self.command_ops:get_shell_info(callback)
end

function RemoteProvider:get_environment(callback)
  self.command_ops:get_environment(callback)
end

function RemoteProvider:set_environment(env_vars, callback)
  self.command_ops:set_environment(env_vars, callback)
end

-- Batch operations
function RemoteProvider:execute_batch_commands(commands, callback, options)
  self.command_ops:execute_batch_commands(commands, callback, options)
end

-- ============================================================================
-- LSP Interface Implementation (Future)
-- ============================================================================

function RemoteProvider:start_lsp_server(language, config, callback)
  local params = {
    language = language,
    config = config or {},
  }
  self:send_rpc_request("orbital.start_lsp_server", params, callback)
end

function RemoteProvider:stop_lsp_server(server_id, callback)
  self:send_rpc_request("orbital.stop_lsp_server", { server_id = server_id }, callback)
end

function RemoteProvider:restart_lsp_server(server_id, callback)
  self:send_rpc_request("orbital.restart_lsp_server", { server_id = server_id }, callback)
end

function RemoteProvider:get_lsp_servers()
  local result = {}
  self:send_rpc_request("orbital.get_lsp_servers", {}, function(success, response)
    if success then
      result = response
    end
  end)
  return result
end

function RemoteProvider:lsp_request(server_id, method, params, callback)
  local rpc_params = {
    server_id = server_id,
    method = method,
    params = params or {},
  }
  self:send_rpc_request("orbital.lsp_request", rpc_params, callback)
end

function RemoteProvider:lsp_notify(server_id, method, params)
  local rpc_params = {
    server_id = server_id,
    method = method,
    params = params or {},
  }
  self:send_rpc_notification("orbital.lsp_notify", rpc_params)
end

function RemoteProvider:lsp_bulk_request(requests, callback)
  self:send_rpc_request("orbital.lsp_bulk_request", { requests = requests }, callback)
end

function RemoteProvider:get_lsp_capabilities(server_id)
  local result = {}
  self:send_rpc_request("orbital.get_lsp_capabilities", { server_id = server_id }, function(success, response)
    if success then
      result = response
    end
  end)
  return result
end

function RemoteProvider:get_server_info(server_id)
  local result = {}
  self:send_rpc_request("orbital.get_server_info", { server_id = server_id }, function(success, response)
    if success then
      result = response
    end
  end)
  return result
end

function RemoteProvider:is_server_ready(server_id)
  local result = false
  self:send_rpc_request("orbital.is_server_ready", { server_id = server_id }, function(success, response)
    if success then
      result = response
    end
  end)
  return result
end

-- Document management
function RemoteProvider:open_document(server_id, uri, content, callback)
  local params = {
    server_id = server_id,
    uri = uri,
    content = content
  }
  self:send_rpc_request("orbital.open_document", params, callback)
end

function RemoteProvider:close_document(server_id, uri, callback)
  local params = {
    server_id = server_id,
    uri = uri
  }
  self:send_rpc_request("orbital.close_document", params, callback)
end

function RemoteProvider:sync_document(server_id, uri, changes, callback)
  local params = {
    server_id = server_id,
    uri = uri,
    changes = changes
  }
  self:send_rpc_request("orbital.sync_document", params, callback)
end

-- ============================================================================
-- Cache Management
-- ============================================================================

function RemoteProvider:invalidate_cache(pattern)
  self.filesystem_ops:invalidate_cache(pattern)
end

function RemoteProvider:clear_cache()
  self.cache_manager:clear()
end

function RemoteProvider:get_cache_stats()
  return {
    general = self.cache_manager:get_stats(),
    filesystem = self.filesystem_ops:get_cache_stats()
  }
end

-- ============================================================================
-- Configuration and Management
-- ============================================================================

function RemoteProvider:configure(config)
  if config.connection then
    self.connection_manager:update_config(config.connection)
  end
  
  if config.rpc then
    self.rpc_client:configure(config.rpc)
  end
  
  if config.filesystem then
    self.filesystem_ops:configure(config.filesystem)
  end
  
  if config.command then
    self.command_ops:configure(config.command)
  end
  
  if config.cache then
    self.cache_manager:configure(config.cache)
  end
end

function RemoteProvider:cleanup()
  Utils.log("🧹 Cleaning up remote provider")
  
  -- Cleanup modules in dependency order
  if self.command_ops then
    self.command_ops:cleanup()
  end
  
  if self.filesystem_ops then
    -- Filesystem ops doesn't have cleanup, but we could add cache cleanup
  end
  
  if self.rpc_client then
    self.rpc_client:cleanup()
  end
  
  if self.connection_manager then
    self.connection_manager:cleanup()
  end
  
  if self.cache_manager then
    self.cache_manager:shutdown()
  end
end

return RemoteProvider


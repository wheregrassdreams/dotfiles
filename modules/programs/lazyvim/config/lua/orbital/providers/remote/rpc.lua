-- orbital/client/providers/remote/rpc.lua
-- RPC Communication Layer for Remote Provider

local Utils = require("orbital.utils")

local RPCClient = {}
RPCClient.__index = RPCClient

function RPCClient.new(connection_manager)
  local self = setmetatable({}, RPCClient)
  
  self.connection_manager = connection_manager
  
  -- Request tracking
  self.pending_requests = {}
  self.request_id_counter = 0
  
  -- Request batching
  self.batch_requests = {}
  self.batch_timer = nil
  self.batch_delay = 50  -- ms
  self.max_batch_size = 10
  
  -- Request retry configuration
  self.max_retries = 3
  self.retry_delay = 1000  -- ms
  
  -- Performance tracking
  self.request_stats = {
    total_requests = 0,
    successful_requests = 0,
    failed_requests = 0,
    retry_requests = 0,
    avg_response_time = 0,
    response_times = {}
  }
  
  return self
end

-- ============================================================================
-- Core RPC Methods
-- ============================================================================

function RPCClient:request(method, params, callback, options)
  options = options or {}
  
  if not self.connection_manager:is_connected() then
    if callback then callback(false, "Not connected to remote server") end
    return
  end
  
  local request_id = self:generate_request_id()
  local start_time = vim.loop.hrtime()
  
  local request_data = {
    id = request_id,
    method = method,
    params = params,
    callback = callback,
    start_time = start_time,
    retry_count = 0,
    max_retries = options.max_retries or self.max_retries,
    timeout = options.timeout or 5000  -- 5 seconds default
  }
  
  -- Track pending request
  self.pending_requests[request_id] = request_data
  
  -- Enable batching for eligible requests
  if options.batch and not options.priority then
    self:add_to_batch(request_data)
  else
    self:send_request(request_data)
  end
  
  return request_id
end

function RPCClient:send_request(request_data)
  local rpc_client = self.connection_manager:get_rpc_client()
  if not rpc_client then
    self:handle_request_error(request_data, "No RPC client available")
    return
  end
  
  -- Set up timeout
  local timeout_timer = nil
  if request_data.timeout > 0 then
    timeout_timer = vim.loop.new_timer()
    timeout_timer:start(request_data.timeout, 0, function()
      vim.schedule(function()
        if self.pending_requests[request_data.id] then
          self:handle_request_timeout(request_data)
        end
        timeout_timer:close()
      end)
    end)
  end
  
  vim.schedule(function()
    local ok, result = pcall(function()
      return rpc_client:request(request_data.method, request_data.params)
    end)
    
    -- Cancel timeout if request completed
    if timeout_timer then
      timeout_timer:close()
    end
    
    if ok then
      self:handle_request_success(request_data, result)
    else
      self:handle_request_error(request_data, result)
    end
  end)
end

function RPCClient:notify(method, params)
  if not self.connection_manager:is_connected() then
    return false
  end
  
  local rpc_client = self.connection_manager:get_rpc_client()
  if not rpc_client then
    return false
  end
  
  vim.schedule(function()
    pcall(function()
      rpc_client:notify(method, params)
    end)
  end)
  
  return true
end

-- ============================================================================
-- Request Batching
-- ============================================================================

function RPCClient:add_to_batch(request_data)
  table.insert(self.batch_requests, request_data)
  
  -- Send batch if we hit the size limit
  if #self.batch_requests >= self.max_batch_size then
    self:send_batch()
  else
    -- Set up batch timer if not already running
    if not self.batch_timer then
      self.batch_timer = vim.loop.new_timer()
      self.batch_timer:start(self.batch_delay, 0, function()
        vim.schedule(function()
          self:send_batch()
        end)
      end)
    end
  end
end

function RPCClient:send_batch()
  if self.batch_timer then
    self.batch_timer:close()
    self.batch_timer = nil
  end
  
  if #self.batch_requests == 0 then
    return
  end
  
  local batch = self.batch_requests
  self.batch_requests = {}
  
  -- For now, send requests individually
  -- Future: implement proper batch RPC protocol
  for _, request_data in ipairs(batch) do
    self:send_request(request_data)
  end
end

-- ============================================================================
-- Request Handling
-- ============================================================================

function RPCClient:handle_request_success(request_data, result)
  local response_time = (vim.loop.hrtime() - request_data.start_time) / 1e6
  
  -- Update statistics
  self:update_stats(true, response_time)
  
  -- Clean up pending request
  self.pending_requests[request_data.id] = nil
  
  -- Call callback
  if request_data.callback then
    request_data.callback(true, result)
  end
end

function RPCClient:handle_request_error(request_data, error_msg)
  -- Check if we should retry
  if request_data.retry_count < request_data.max_retries then
    self:retry_request(request_data, error_msg)
    return
  end
  
  -- Update statistics
  self:update_stats(false)
  
  -- Clean up pending request
  self.pending_requests[request_data.id] = nil
  
  -- Determine if this is a connection issue
  local is_connection_error = self:is_connection_error(error_msg)
  
  if is_connection_error and self.connection_manager.auto_reconnect then
    -- Trigger reconnection
    Utils.log("🔄 RPC request failed due to connection issue, attempting reconnect...")
    self.connection_manager:reconnect(function(reconnect_success)
      if reconnect_success then
        -- Retry the original request after reconnection
        request_data.retry_count = 0  -- Reset retry count after reconnection
        self:send_request(request_data)
      else
        -- Final failure
        if request_data.callback then
          request_data.callback(false, "RPC failed and reconnection failed: " .. tostring(error_msg))
        end
      end
    end)
  else
    -- Call callback with error
    if request_data.callback then
      request_data.callback(false, "RPC request failed: " .. tostring(error_msg))
    end
  end
end

function RPCClient:handle_request_timeout(request_data)
  Utils.log("⏰ RPC request timeout: " .. request_data.method)
  self:handle_request_error(request_data, "Request timeout")
end

function RPCClient:retry_request(request_data, error_msg)
  request_data.retry_count = request_data.retry_count + 1
  
  Utils.log("🔄 Retrying RPC request (" .. request_data.retry_count .. "/" .. request_data.max_retries .. "): " .. request_data.method)
  
  -- Update retry statistics
  self.request_stats.retry_requests = self.request_stats.retry_requests + 1
  
  -- Delay before retry
  vim.defer_fn(function()
    if self.pending_requests[request_data.id] then  -- Check if request is still pending
      self:send_request(request_data)
    end
  end, self.retry_delay)
end

-- ============================================================================
-- Helper Methods
-- ============================================================================

function RPCClient:generate_request_id()
  self.request_id_counter = self.request_id_counter + 1
  return "rpc_" .. self.request_id_counter .. "_" .. os.time()
end

function RPCClient:is_connection_error(error_msg)
  local connection_errors = {
    "connection closed",
    "broken pipe",
    "connection reset",
    "connection refused",
    "network unreachable",
    "timeout"
  }
  
  local error_str = tostring(error_msg):lower()
  for _, err_pattern in ipairs(connection_errors) do
    if error_str:find(err_pattern, 1, true) then
      return true
    end
  end
  
  return false
end

-- ============================================================================
-- Statistics and Monitoring
-- ============================================================================

function RPCClient:update_stats(success, response_time)
  self.request_stats.total_requests = self.request_stats.total_requests + 1
  
  if success then
    self.request_stats.successful_requests = self.request_stats.successful_requests + 1
    
    if response_time then
      table.insert(self.request_stats.response_times, response_time)
      
      -- Keep only recent response times (last 100)
      if #self.request_stats.response_times > 100 then
        table.remove(self.request_stats.response_times, 1)
      end
      
      -- Calculate average response time
      local total_time = 0
      for _, time in ipairs(self.request_stats.response_times) do
        total_time = total_time + time
      end
      self.request_stats.avg_response_time = total_time / #self.request_stats.response_times
    end
  else
    self.request_stats.failed_requests = self.request_stats.failed_requests + 1
  end
end

function RPCClient:get_stats()
  local stats = vim.deepcopy(self.request_stats)
  stats.pending_requests = vim.tbl_count(self.pending_requests)
  stats.success_rate = self.request_stats.total_requests > 0 
    and (self.request_stats.successful_requests / self.request_stats.total_requests * 100) 
    or 0
  
  return stats
end

function RPCClient:reset_stats()
  self.request_stats = {
    total_requests = 0,
    successful_requests = 0,
    failed_requests = 0,
    retry_requests = 0,
    avg_response_time = 0,
    response_times = {}
  }
end

-- ============================================================================
-- Configuration
-- ============================================================================

function RPCClient:configure(config)
  if config.max_retries then
    self.max_retries = config.max_retries
  end
  
  if config.retry_delay then
    self.retry_delay = config.retry_delay
  end
  
  if config.batch_delay then
    self.batch_delay = config.batch_delay
  end
  
  if config.max_batch_size then
    self.max_batch_size = config.max_batch_size
  end
end

-- ============================================================================
-- Cleanup
-- ============================================================================

function RPCClient:cleanup()
  -- Cancel all pending requests
  for request_id, request_data in pairs(self.pending_requests) do
    if request_data.callback then
      request_data.callback(false, "RPC client shutting down")
    end
  end
  self.pending_requests = {}
  
  -- Clear batch
  self.batch_requests = {}
  if self.batch_timer then
    self.batch_timer:close()
    self.batch_timer = nil
  end
end

return RPCClient
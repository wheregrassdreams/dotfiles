-- orbital/client/providers/remote/commands.lua
-- Command Operations for Remote Provider

local Utils = require("orbital.utils")

local CommandOps = {}
CommandOps.__index = CommandOps

function CommandOps.new(rpc_client)
  local self = setmetatable({}, CommandOps)

  self.rpc_client = rpc_client

  -- Job management
  self.active_jobs = {}
  self.job_history = {}
  self.max_history_size = 100

  -- Command configuration
  self.default_timeout = 30000 -- 30 seconds
  self.max_concurrent_jobs = 10
  self.enable_job_streaming = true

  -- Command history
  self.command_history = {}
  self.max_command_history = 50

  return self
end

-- ============================================================================
-- Core Command Operations
-- ============================================================================

function CommandOps:execute_command(cmd, args, callback, options)
  options = options or {}

  -- Prepare command parameters
  local params = {
    cmd = cmd,
    args = args or {},
    cwd = options.cwd,
    env = options.env,
    timeout = options.timeout or self.default_timeout,
    capture_output = options.capture_output ~= false, -- Default to true
  }

  -- Add to command history
  self:add_to_history(cmd, args)

  local request_options = {
    timeout = (options.timeout or self.default_timeout) + 5000, -- Add buffer to RPC timeout
    priority = options.priority,
    max_retries = options.max_retries or 1, -- Commands usually shouldn't be retried
  }

  self.rpc_client:request("orbital.execute_command", params, function(success, result)
    if success and result.output then
      -- Store in job history for reference
      self:add_to_job_history({
        type = "sync",
        cmd = cmd,
        args = args,
        success = success,
        output = result.output,
        exit_code = result.exit_code,
        duration = result.duration,
        timestamp = os.time(),
      })
    end

    callback(success, result)
  end, request_options)
end

function CommandOps:execute_async(cmd, args, callback, options)
  options = options or {}

  -- Check concurrent job limit
  if vim.tbl_count(self.active_jobs) >= self.max_concurrent_jobs then
    if callback then
      callback(false, "Maximum concurrent jobs reached")
    end
    return
  end

  local params = {
    cmd = cmd,
    args = args or {},
    cwd = options.cwd,
    env = options.env,
    timeout = options.timeout or self.default_timeout,
    stream_output = options.stream_output and self.enable_job_streaming,
  }

  -- Add to command history
  self:add_to_history(cmd, args)

  self.rpc_client:request("orbital.execute_async", params, function(success, result)
    if success then
      -- Track the job
      local job_id = result.job_id
      self.active_jobs[job_id] = {
        cmd = cmd,
        args = args,
        start_time = os.time(),
        status = "running",
        options = options,
        callback = options.completion_callback, -- Optional completion callback
      }

      -- Set up job monitoring if streaming is enabled
      if options.stream_output and self.enable_job_streaming then
        self:start_job_monitoring(job_id, options.output_callback)
      end
    end

    callback(success, result)
  end, { timeout = 10000 }) -- Quick timeout for job start
end

function CommandOps:execute_shell(command_string, callback, options)
  options = options or {}

  local params = {
    command = command_string,
    shell = options.shell,
    cwd = options.cwd,
    env = options.env,
    timeout = options.timeout or self.default_timeout,
  }

  -- Add to command history
  self:add_to_history("shell", { command_string })

  local request_options = {
    timeout = (options.timeout or self.default_timeout) + 5000,
    priority = options.priority,
    max_retries = options.max_retries or 1,
  }

  self.rpc_client:request("orbital.execute_shell", params, function(success, result)
    if success then
      self:add_to_job_history({
        type = "shell",
        command = command_string,
        success = success,
        output = result.output,
        exit_code = result.exit_code,
        duration = result.duration,
        timestamp = os.time(),
      })
    end

    callback(success, result)
  end, request_options)
end

-- ============================================================================
-- Job Management
-- ============================================================================

function CommandOps:get_job_status(job_id, callback)
  if callback then
    -- Async version
    self.rpc_client:request("orbital.get_job_status", { job_id = job_id }, function(success, result)
      if success and self.active_jobs[job_id] then
        -- Update local job tracking
        self.active_jobs[job_id].status = result.status
        if result.status == "completed" or result.status == "failed" then
          self:handle_job_completion(job_id, result)
        end
      end

      callback(success, result)
    end)
  else
    -- Return cached status if available
    local job = self.active_jobs[job_id]
    if job then
      return {
        status = job.status,
        start_time = job.start_time,
        cmd = job.cmd,
        args = job.args,
      }
    end

    return { status = "unknown" }
  end
end

function CommandOps:cancel_job(job_id, callback)
  self.rpc_client:request("orbital.cancel_job", { job_id = job_id }, function(success, result)
    if success and self.active_jobs[job_id] then
      self.active_jobs[job_id].status = "cancelled"
      self:handle_job_completion(job_id, {
        status = "cancelled",
        exit_code = -1,
        output = "Job cancelled by user",
      })
    end

    if callback then
      callback(success, result)
    end
  end, { priority = true })
end

function CommandOps:wait_for_job(job_id, callback, timeout)
  timeout = timeout or 30000 -- 30 second default

  local start_time = vim.loop.hrtime()
  local check_interval = 1000 -- Check every second

  local function check_job()
    self:get_job_status(job_id, function(success, result)
      if success and (result.status == "completed" or result.status == "failed" or result.status == "cancelled") then
        callback(true, result)
      else
        local elapsed = (vim.loop.hrtime() - start_time) / 1e6
        if elapsed >= timeout then
          callback(false, "Job wait timeout")
        else
          vim.defer_fn(check_job, check_interval)
        end
      end
    end)
  end

  check_job()
end

function CommandOps:list_active_jobs()
  local jobs = {}
  for job_id, job_info in pairs(self.active_jobs) do
    table.insert(jobs, {
      id = job_id,
      cmd = job_info.cmd,
      args = job_info.args,
      status = job_info.status,
      start_time = job_info.start_time,
      duration = os.time() - job_info.start_time,
    })
  end
  return jobs
end

-- ============================================================================
-- Job Monitoring and Streaming
-- ============================================================================

function CommandOps:start_job_monitoring(job_id, output_callback)
  if not self.enable_job_streaming then
    return
  end

  local monitor_interval = 2000 -- Check every 2 seconds

  local function monitor()
    if not self.active_jobs[job_id] then
      return -- Job no longer active
    end

    self.rpc_client:request("orbital.get_job_output", {
      job_id = job_id,
      stream = true,
    }, function(success, result)
      if success then
        if result.output and output_callback then
          output_callback(result.output, result.is_complete)
        end

        if result.status and (result.status == "completed" or result.status == "failed") then
          self:handle_job_completion(job_id, result)
        else
          -- Continue monitoring
          vim.defer_fn(monitor, monitor_interval)
        end
      end
    end, { timeout = 5000 })
  end

  -- Start monitoring after a short delay
  vim.defer_fn(monitor, 1000)
end

function CommandOps:handle_job_completion(job_id, result)
  local job = self.active_jobs[job_id]
  if not job then
    return
  end

  -- Add to job history
  self:add_to_job_history({
    type = "async",
    job_id = job_id,
    cmd = job.cmd,
    args = job.args,
    success = result.status == "completed",
    output = result.output,
    exit_code = result.exit_code,
    duration = result.duration or (os.time() - job.start_time),
    timestamp = os.time(),
  })

  -- Call completion callback if provided
  if job.callback then
    job.callback(result.status == "completed", result)
  end

  -- Remove from active jobs
  self.active_jobs[job_id] = nil
end

-- ============================================================================
-- Command and Job History
-- ============================================================================

function CommandOps:add_to_history(cmd, args)
  table.insert(self.command_history, {
    cmd = cmd,
    args = args,
    timestamp = os.time(),
  })

  -- Limit history size
  if #self.command_history > self.max_command_history then
    table.remove(self.command_history, 1)
  end
end

function CommandOps:add_to_job_history(job_result)
  table.insert(self.job_history, job_result)

  -- Limit history size
  if #self.job_history > self.max_history_size then
    table.remove(self.job_history, 1)
  end
end

function CommandOps:get_command_history(limit)
  limit = limit or #self.command_history
  local history = {}

  local start_idx = math.max(1, #self.command_history - limit + 1)
  for i = start_idx, #self.command_history do
    table.insert(history, self.command_history[i])
  end

  return history
end

function CommandOps:get_job_history(limit)
  limit = limit or #self.job_history
  local history = {}

  local start_idx = math.max(1, #self.job_history - limit + 1)
  for i = start_idx, #self.job_history do
    table.insert(history, self.job_history[i])
  end

  return history
end

function CommandOps:clear_history()
  self.command_history = {}
  self.job_history = {}
end

-- ============================================================================
-- Shell Information and Environment
-- ============================================================================

function CommandOps:get_shell_info(callback)
  self.rpc_client:request("orbital.get_shell_info", {}, callback)
end

function CommandOps:get_environment(callback)
  self.rpc_client:request("orbital.get_environment", {}, callback)
end

function CommandOps:set_environment(env_vars, callback)
  self.rpc_client:request("orbital.set_environment", { env_vars = env_vars }, callback, { priority = true })
end

-- ============================================================================
-- Batch Operations
-- ============================================================================

function CommandOps:execute_batch_commands(commands, callback, options)
  options = options or {}

  if #commands > 20 then -- Limit batch size
    callback(false, "Too many commands in batch (max 20)")
    return
  end

  local params = {
    commands = commands,
    fail_fast = options.fail_fast ~= false, -- Default to true
    timeout = options.timeout or self.default_timeout,
    parallel = options.parallel or false,
  }

  self.rpc_client:request("orbital.execute_batch_commands", params, function(success, result)
    if success then
      -- Add all commands to history
      for _, cmd_info in ipairs(commands) do
        self:add_to_history(cmd_info.cmd, cmd_info.args)
      end

      -- Add results to job history
      if result.results then
        for i, cmd_result in ipairs(result.results) do
          self:add_to_job_history({
            type = "batch",
            batch_index = i,
            cmd = commands[i].cmd,
            args = commands[i].args,
            success = cmd_result.success,
            output = cmd_result.output,
            exit_code = cmd_result.exit_code,
            duration = cmd_result.duration,
            timestamp = os.time(),
          })
        end
      end
    end

    callback(success, result)
  end, { timeout = (options.timeout or self.default_timeout) + 10000 })
end

-- ============================================================================
-- Configuration and Statistics
-- ============================================================================

function CommandOps:configure(config)
  if config.default_timeout then
    self.default_timeout = config.default_timeout
  end

  if config.max_concurrent_jobs then
    self.max_concurrent_jobs = config.max_concurrent_jobs
  end

  if config.enable_job_streaming ~= nil then
    self.enable_job_streaming = config.enable_job_streaming
  end

  if config.max_history_size then
    self.max_history_size = config.max_history_size
  end

  if config.max_command_history then
    self.max_command_history = config.max_command_history
  end
end

function CommandOps:get_stats()
  return {
    active_jobs = vim.tbl_count(self.active_jobs),
    max_concurrent_jobs = self.max_concurrent_jobs,
    command_history_size = #self.command_history,
    job_history_size = #self.job_history,
    streaming_enabled = self.enable_job_streaming,
  }
end

-- ============================================================================
-- Cleanup
-- ============================================================================

function CommandOps:cleanup()
  -- Cancel all active jobs
  for job_id, _ in pairs(self.active_jobs) do
    self:cancel_job(job_id)
  end

  self.active_jobs = {}
end

return CommandOps


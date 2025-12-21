-- orbital/client/providers/remote/filesystem.lua
-- Filesystem Operations for Remote Provider

local Utils = require("orbital.utils")

local FilesystemOps = {}
FilesystemOps.__index = FilesystemOps

function FilesystemOps.new(rpc_client, cache_manager)
  local self = setmetatable({}, FilesystemOps)
  
  self.rpc_client = rpc_client
  self.cache_manager = cache_manager  -- Optional cache manager
  
  -- Operation configuration
  self.enable_caching = cache_manager ~= nil
  self.cache_ttl = 30000  -- 30 seconds default TTL
  
  -- File watching (future)
  self.watchers = {}
  self.watch_id_counter = 0
  
  -- Performance optimization
  self.batch_operations = true
  self.max_batch_size = 20
  
  return self
end

-- ============================================================================
-- Core File Operations
-- ============================================================================

function FilesystemOps:read_file(path, callback, options)
  options = options or {}
  
  -- Check cache first if enabled
  if self.enable_caching and not options.bypass_cache then
    local cached_content = self.cache_manager:get("file:" .. path)
    if cached_content then
      Utils.log("📋 Cache hit for file: " .. path)
      callback(true, cached_content.content)
      return
    end
  end
  
  local request_options = {
    timeout = options.timeout or 10000,  -- 10 second timeout for file reads
    batch = options.batch,
    max_retries = options.max_retries or 2
  }
  
  self.rpc_client:request("orbital.read_file", { path = path }, function(success, result)
    if success and self.enable_caching then
      -- Cache the result
      self.cache_manager:set("file:" .. path, {
        content = result,
        timestamp = os.time(),
        size = #result
      }, self.cache_ttl)
    end
    
    callback(success, result)
  end, request_options)
end

function FilesystemOps:write_file(path, content, callback, options)
  options = options or {}
  
  local request_options = {
    timeout = options.timeout or 15000,  -- 15 second timeout for file writes
    priority = true,  -- Write operations are high priority
    max_retries = options.max_retries or 3
  }
  
  self.rpc_client:request("orbital.write_file", { 
    path = path, 
    content = content,
    create_dirs = options.create_dirs,
    backup = options.backup
  }, function(success, result)
    if success and self.enable_caching then
      -- Update cache
      self.cache_manager:set("file:" .. path, {
        content = content,
        timestamp = os.time(),
        size = #content
      }, self.cache_ttl)
      
      -- Invalidate directory cache
      local dir_path = path:match("^(.+)/[^/]+$") or "."
      self.cache_manager:invalidate("dir:" .. dir_path)
    end
    
    callback(success, result)
  end, request_options)
end

function FilesystemOps:delete_file(path, callback, options)
  options = options or {}
  
  self.rpc_client:request("orbital.delete_file", { 
    path = path,
    force = options.force
  }, function(success, result)
    if success and self.enable_caching then
      -- Remove from cache
      self.cache_manager:invalidate("file:" .. path)
      
      -- Invalidate directory cache
      local dir_path = path:match("^(.+)/[^/]+$") or "."
      self.cache_manager:invalidate("dir:" .. dir_path)
    end
    
    callback(success, result)
  end, { priority = true })
end

function FilesystemOps:copy_file(src, dest, callback, options)
  options = options or {}
  
  self.rpc_client:request("orbital.copy_file", {
    src = src,
    dest = dest,
    overwrite = options.overwrite,
    preserve_attrs = options.preserve_attrs
  }, function(success, result)
    if success and self.enable_caching then
      -- Invalidate affected directory caches
      local src_dir = src:match("^(.+)/[^/]+$") or "."
      local dest_dir = dest:match("^(.+)/[^/]+$") or "."
      self.cache_manager:invalidate("dir:" .. src_dir)
      if src_dir ~= dest_dir then
        self.cache_manager:invalidate("dir:" .. dest_dir)
      end
    end
    
    callback(success, result)
  end)
end

function FilesystemOps:move_file(src, dest, callback, options)
  options = options or {}
  
  self.rpc_client:request("orbital.move_file", {
    src = src,
    dest = dest,
    overwrite = options.overwrite
  }, function(success, result)
    if success and self.enable_caching then
      -- Remove old file from cache and invalidate directories
      self.cache_manager:invalidate("file:" .. src)
      
      local src_dir = src:match("^(.+)/[^/]+$") or "."
      local dest_dir = dest:match("^(.+)/[^/]+$") or "."
      self.cache_manager:invalidate("dir:" .. src_dir)
      if src_dir ~= dest_dir then
        self.cache_manager:invalidate("dir:" .. dest_dir)
      end
    end
    
    callback(success, result)
  end)
end

-- ============================================================================
-- Directory Operations
-- ============================================================================

function FilesystemOps:list_files(path, callback, options)
  options = options or {}
  
  -- Check cache first if enabled
  if self.enable_caching and not options.bypass_cache then
    local cached_listing = self.cache_manager:get("dir:" .. path)
    if cached_listing then
      Utils.log("📋 Cache hit for directory: " .. path)
      callback(true, cached_listing.items)
      return
    end
  end
  
  local request_options = {
    timeout = options.timeout or 8000,
    batch = options.batch,
    max_retries = options.max_retries or 2
  }
  
  self.rpc_client:request("orbital.list_files", { 
    path = path,
    recursive = options.recursive,
    include_hidden = options.include_hidden,
    file_types = options.file_types
  }, function(success, result)
    if success and self.enable_caching then
      -- Cache the directory listing
      self.cache_manager:set("dir:" .. path, {
        items = result,
        timestamp = os.time(),
        count = #result
      }, self.cache_ttl / 2)  -- Shorter TTL for directory listings
    end
    
    callback(success, result)
  end, request_options)
end

function FilesystemOps:create_dir(path, callback, options)
  options = options or {}
  
  self.rpc_client:request("orbital.create_dir", {
    path = path,
    recursive = options.recursive or true,
    mode = options.mode
  }, function(success, result)
    if success and self.enable_caching then
      -- Invalidate parent directory cache
      local parent_dir = path:match("^(.+)/[^/]+$") or "."
      self.cache_manager:invalidate("dir:" .. parent_dir)
    end
    
    callback(success, result)
  end, { priority = true })
end

function FilesystemOps:delete_dir(path, callback, options)
  options = options or {}
  
  self.rpc_client:request("orbital.delete_dir", {
    path = path,
    recursive = options.recursive,
    force = options.force
  }, function(success, result)
    if success and self.enable_caching then
      -- Invalidate directory and parent caches
      self.cache_manager:invalidate_pattern("dir:" .. path .. ".*")
      
      local parent_dir = path:match("^(.+)/[^/]+$") or "."
      self.cache_manager:invalidate("dir:" .. parent_dir)
    end
    
    callback(success, result)
  end, { priority = true })
end

function FilesystemOps:get_cwd(callback)
  -- CWD can be cached for a short time
  if self.enable_caching then
    local cached_cwd = self.cache_manager:get("cwd")
    if cached_cwd then
      callback(true, cached_cwd.path)
      return
    end
  end
  
  self.rpc_client:request("orbital.get_cwd", {}, function(success, result)
    if success and self.enable_caching then
      self.cache_manager:set("cwd", {
        path = result,
        timestamp = os.time()
      }, 5000)  -- 5 second TTL for CWD
    end
    
    callback(success, result)
  end)
end

function FilesystemOps:change_dir(path, callback)
  self.rpc_client:request("orbital.change_dir", { path = path }, function(success, result)
    if success and self.enable_caching then
      -- Invalidate CWD cache
      self.cache_manager:invalidate("cwd")
    end
    
    callback(success, result)
  end, { priority = true })
end

-- ============================================================================
-- File Information
-- ============================================================================

function FilesystemOps:get_file_info(path, callback, options)
  options = options or {}
  
  -- Check cache for file info
  if self.enable_caching and not options.bypass_cache then
    local cached_info = self.cache_manager:get("info:" .. path)
    if cached_info then
      callback(true, cached_info.info)
      return
    end
  end
  
  self.rpc_client:request("orbital.get_file_info", { 
    path = path,
    include_checksum = options.include_checksum
  }, function(success, result)
    if success and self.enable_caching then
      self.cache_manager:set("info:" .. path, {
        info = result,
        timestamp = os.time()
      }, self.cache_ttl)
    end
    
    callback(success, result)
  end)
end

-- ============================================================================
-- Batch Operations
-- ============================================================================

function FilesystemOps:batch_read_files(paths, callback, options)
  options = options or {}
  
  if not self.batch_operations or #paths > self.max_batch_size then
    -- Fall back to individual reads
    local results = {}
    local completed = 0
    local has_error = false
    
    for i, path in ipairs(paths) do
      self:read_file(path, function(success, result)
        completed = completed + 1
        results[i] = { path = path, success = success, result = result }
        
        if not success then has_error = true end
        
        if completed == #paths then
          callback(not has_error, results)
        end
      end, { batch = true })
    end
    
    return
  end
  
  -- Use batch RPC call
  self.rpc_client:request("orbital.batch_read_files", { paths = paths }, callback, options)
end

function FilesystemOps:batch_write_files(file_operations, callback, options)
  options = options or {}
  
  if not self.batch_operations or #file_operations > self.max_batch_size then
    -- Fall back to individual writes
    local completed = 0
    local has_error = false
    local results = {}
    
    for i, op in ipairs(file_operations) do
      self:write_file(op.path, op.content, function(success, result)
        completed = completed + 1
        results[i] = { path = op.path, success = success, result = result }
        
        if not success then has_error = true end
        
        if completed == #file_operations then
          callback(not has_error, results)
        end
      end, { batch = true })
    end
    
    return
  end
  
  -- Use batch RPC call
  self.rpc_client:request("orbital.batch_write_files", { operations = file_operations }, function(success, result)
    if success and self.enable_caching then
      -- Invalidate caches for all affected files and directories
      for _, op in ipairs(file_operations) do
        self.cache_manager:invalidate("file:" .. op.path)
        local dir_path = op.path:match("^(.+)/[^/]+$") or "."
        self.cache_manager:invalidate("dir:" .. dir_path)
      end
    end
    
    callback(success, result)
  end, options)
end

-- ============================================================================
-- File Watching (Future)
-- ============================================================================

function FilesystemOps:watch_file(path, callback, options)
  options = options or {}
  
  local watch_id = "watch_" .. self.watch_id_counter .. "_" .. os.time()
  self.watch_id_counter = self.watch_id_counter + 1
  
  self.rpc_client:request("orbital.watch_file", {
    path = path,
    watch_id = watch_id,
    events = options.events or {"modify", "create", "delete"}
  }, function(success, result)
    if success then
      self.watchers[watch_id] = {
        path = path,
        callback = callback,
        options = options
      }
    end
    
    callback(success, success and watch_id or result)
  end)
  
  return watch_id
end

function FilesystemOps:unwatch_file(watch_id, callback)
  if not self.watchers[watch_id] then
    if callback then callback(false, "Watch ID not found") end
    return
  end
  
  self.rpc_client:request("orbital.unwatch_file", { watch_id = watch_id }, function(success, result)
    if success then
      self.watchers[watch_id] = nil
    end
    
    if callback then callback(success, result) end
  end)
end

-- ============================================================================
-- Cache Management
-- ============================================================================

function FilesystemOps:invalidate_cache(pattern)
  if self.enable_caching then
    if pattern then
      self.cache_manager:invalidate_pattern(pattern)
    else
      self.cache_manager:clear()
    end
  end
end

function FilesystemOps:get_cache_stats()
  if self.enable_caching then
    return self.cache_manager:get_stats()
  end
  return { enabled = false }
end

-- ============================================================================
-- Configuration
-- ============================================================================

function FilesystemOps:configure(config)
  if config.cache_ttl then
    self.cache_ttl = config.cache_ttl
  end
  
  if config.enable_caching ~= nil then
    self.enable_caching = config.enable_caching and self.cache_manager ~= nil
  end
  
  if config.batch_operations ~= nil then
    self.batch_operations = config.batch_operations
  end
  
  if config.max_batch_size then
    self.max_batch_size = config.max_batch_size
  end
end

return FilesystemOps
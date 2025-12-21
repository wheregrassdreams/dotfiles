-- orbital/client/providers/remote/cache.lua
-- Cache Management for Remote Provider Operations

local Utils = require("orbital.utils")

local CacheManager = {}
CacheManager.__index = CacheManager

function CacheManager.new(config)
  local self = setmetatable({}, CacheManager)

  config = config or {}

  -- Cache storage
  self.cache = {}
  self.access_times = {}
  self.creation_times = {}
  self.ttl_timers = {}

  -- Configuration
  self.max_size = config.max_size or 1000 -- Maximum number of cached items
  self.default_ttl = config.default_ttl or 300000 -- 5 minutes default TTL (ms)
  self.cleanup_interval = config.cleanup_interval or 60000 -- Cleanup every minute
  self.max_memory_mb = config.max_memory_mb or 100 -- Maximum memory usage in MB

  -- LRU eviction policy
  self.eviction_policy = config.eviction_policy or "lru" -- lru, lfu, fifo
  self.access_counts = {}

  -- Statistics
  self.stats = {
    hits = 0,
    misses = 0,
    evictions = 0,
    memory_usage = 0,
    total_sets = 0,
    total_gets = 0,
    cleanup_runs = 0,
  }

  -- Cleanup timer
  self.cleanup_timer = nil
  self:start_cleanup_timer()

  return self
end

-- ============================================================================
-- Core Cache Operations
-- ============================================================================

function CacheManager:get(key)
  self.stats.total_gets = self.stats.total_gets + 1

  local value = self.cache[key]
  if not value then
    self.stats.misses = self.stats.misses + 1
    return nil
  end

  -- Check if expired
  if self:is_expired(key) then
    self:delete(key)
    self.stats.misses = self.stats.misses + 1
    return nil
  end

  -- Update access tracking
  self.access_times[key] = os.time()
  if self.eviction_policy == "lfu" then
    self.access_counts[key] = (self.access_counts[key] or 0) + 1
  end

  self.stats.hits = self.stats.hits + 1
  return value
end

function CacheManager:set(key, value, ttl)
  self.stats.total_sets = self.stats.total_sets + 1

  -- Remove existing entry if present
  if self.cache[key] then
    self:delete(key)
  end

  -- Check size limits before adding
  if self:should_evict() then
    self:evict_items()
  end

  -- Store value
  self.cache[key] = value
  self.creation_times[key] = os.time()
  self.access_times[key] = os.time()

  if self.eviction_policy == "lfu" then
    self.access_counts[key] = 1
  end

  -- Set TTL timer if specified
  local effective_ttl = ttl or self.default_ttl
  if effective_ttl > 0 then
    self:set_ttl_timer(key, effective_ttl)
  end

  -- Update memory usage estimate
  self:update_memory_usage()

  Utils.log("💾 Cache SET: " .. key .. " (TTL: " .. effective_ttl .. "ms)")
end

function CacheManager:delete(key)
  if not self.cache[key] then
    return false
  end

  self.cache[key] = nil
  self.access_times[key] = nil
  self.creation_times[key] = nil
  self.access_counts[key] = nil

  -- Cancel TTL timer
  if self.ttl_timers[key] then
    self.ttl_timers[key]:close()
    self.ttl_timers[key] = nil
  end

  self:update_memory_usage()
  Utils.log("🗑️ Cache DELETE: " .. key)
  return true
end

function CacheManager:has(key)
  return self.cache[key] ~= nil and not self:is_expired(key)
end

function CacheManager:clear()
  -- Cancel all TTL timers
  for key, timer in pairs(self.ttl_timers) do
    timer:close()
  end

  self.cache = {}
  self.access_times = {}
  self.creation_times = {}
  self.access_counts = {}
  self.ttl_timers = {}

  self.stats.memory_usage = 0
  Utils.log("🧹 Cache cleared")
end

-- ============================================================================
-- Advanced Cache Operations
-- ============================================================================

function CacheManager:invalidate_pattern(pattern)
  local invalidated_keys = {}

  for key, _ in pairs(self.cache) do
    if key:match(pattern) then
      self:delete(key)
      table.insert(invalidated_keys, key)
    end
  end

  Utils.log("🎯 Cache invalidated " .. #invalidated_keys .. " keys matching: " .. pattern)
  return invalidated_keys
end

function CacheManager:invalidate(key)
  return self:delete(key)
end

function CacheManager:touch(key, ttl)
  if not self.cache[key] then
    return false
  end

  self.access_times[key] = os.time()

  -- Reset TTL if provided
  if ttl then
    if self.ttl_timers[key] then
      self.ttl_timers[key]:close()
    end
    self:set_ttl_timer(key, ttl)
  end

  return true
end

function CacheManager:get_or_set(key, value_fn, ttl)
  local value = self:get(key)
  if value then
    return value
  end

  -- Generate value
  local new_value = value_fn()
  if new_value then
    self:set(key, new_value, ttl)
  end

  return new_value
end

-- ============================================================================
-- Memory and Size Management
-- ============================================================================

function CacheManager:should_evict()
  local size_limit_reached = vim.tbl_count(self.cache) >= self.max_size
  local memory_limit_reached = self:estimate_memory_usage() > (self.max_memory_mb * 1024 * 1024)

  return size_limit_reached or memory_limit_reached
end

function CacheManager:evict_items()
  local items_to_evict = math.max(1, math.floor(self.max_size * 0.1)) -- Evict 10% when full
  local evicted = 0

  local keys_by_priority = self:get_eviction_candidates()

  for _, key in ipairs(keys_by_priority) do
    if evicted >= items_to_evict then
      break
    end

    self:delete(key)
    evicted = evicted + 1
    self.stats.evictions = self.stats.evictions + 1
  end

  Utils.log("♻️ Cache evicted " .. evicted .. " items (" .. self.eviction_policy .. " policy)")
end

function CacheManager:get_eviction_candidates()
  local candidates = {}

  for key, _ in pairs(self.cache) do
    table.insert(candidates, key)
  end

  if self.eviction_policy == "lru" then
    -- Sort by access time (oldest first)
    table.sort(candidates, function(a, b)
      return self.access_times[a] < self.access_times[b]
    end)
  elseif self.eviction_policy == "lfu" then
    -- Sort by access count (least frequent first)
    table.sort(candidates, function(a, b)
      local count_a = self.access_counts[a] or 0
      local count_b = self.access_counts[b] or 0
      return count_a < count_b
    end)
  else -- fifo
    -- Sort by creation time (oldest first)
    table.sort(candidates, function(a, b)
      return self.creation_times[a] < self.creation_times[b]
    end)
  end

  return candidates
end

function CacheManager:estimate_memory_usage()
  local total_size = 0

  for key, value in pairs(self.cache) do
    -- Rough estimate of memory usage
    total_size = total_size + #key
    if type(value) == "string" then
      total_size = total_size + #value
    elseif type(value) == "table" then
      total_size = total_size + self:estimate_table_size(value)
    else
      total_size = total_size + 64 -- Rough estimate for other types
    end
  end

  return total_size
end

function CacheManager:estimate_table_size(tbl)
  local size = 0
  for k, v in pairs(tbl) do
    size = size + (type(k) == "string" and #k or 64)
    if type(v) == "string" then
      size = size + #v
    elseif type(v) == "table" then
      size = size + self:estimate_table_size(v)
    else
      size = size + 64
    end
  end
  return size
end

function CacheManager:update_memory_usage()
  self.stats.memory_usage = self:estimate_memory_usage()
end

-- ============================================================================
-- TTL Management
-- ============================================================================

function CacheManager:is_expired(key)
  local creation_time = self.creation_times[key]
  if not creation_time then
    return true
  end

  -- TTL is handled by timers, so if the key exists, it's not expired
  return false
end

function CacheManager:set_ttl_timer(key, ttl)
  if self.ttl_timers[key] then
    self.ttl_timers[key]:close()
  end

  local timer = vim.loop.new_timer()
  timer:start(ttl, 0, function()
    vim.schedule(function()
      if self.cache[key] then
        Utils.log("⏰ Cache TTL expired: " .. key)
        self:delete(key)
      end
    end)
  end)

  self.ttl_timers[key] = timer
end

-- ============================================================================
-- Maintenance and Cleanup
-- ============================================================================

function CacheManager:start_cleanup_timer()
  if self.cleanup_timer then
    return
  end

  self.cleanup_timer = vim.uv.new_timer()
  self.cleanup_timer:start(self.cleanup_interval, self.cleanup_interval, function()
    vim.schedule(function()
      self:cleanup()
    end)
  end)
end

function CacheManager:stop_cleanup_timer()
  if self.cleanup_timer then
    self.cleanup_timer:stop()
    self.cleanup_timer:close()
    self.cleanup_timer = nil
  end
end

function CacheManager:cleanup()
  self.stats.cleanup_runs = self.stats.cleanup_runs + 1

  -- Force eviction if over limits
  while self:should_evict() do
    self:evict_items()
  end

  -- Update memory usage
  self:update_memory_usage()

  local cache_size = vim.tbl_count(self.cache)
  if cache_size > 0 then
    Utils.log(
      "🧹 Cache cleanup: " .. cache_size .. " items, " .. string.format("%.1fKB", self.stats.memory_usage / 1024)
    )
  end
end

-- ============================================================================
-- Statistics and Monitoring
-- ============================================================================

function CacheManager:get_stats()
  local cache_size = vim.tbl_count(self.cache)
  local hit_rate = self.stats.total_gets > 0 and (self.stats.hits / self.stats.total_gets * 100) or 0

  return {
    size = cache_size,
    max_size = self.max_size,
    memory_usage_bytes = self.stats.memory_usage,
    memory_usage_mb = self.stats.memory_usage / (1024 * 1024),
    max_memory_mb = self.max_memory_mb,
    hit_rate = hit_rate,
    hits = self.stats.hits,
    misses = self.stats.misses,
    evictions = self.stats.evictions,
    total_sets = self.stats.total_sets,
    total_gets = self.stats.total_gets,
    cleanup_runs = self.stats.cleanup_runs,
    eviction_policy = self.eviction_policy,
  }
end

function CacheManager:reset_stats()
  self.stats = {
    hits = 0,
    misses = 0,
    evictions = 0,
    memory_usage = self.stats.memory_usage, -- Keep current memory usage
    total_sets = 0,
    total_gets = 0,
    cleanup_runs = 0,
  }
end

function CacheManager:get_keys()
  local keys = {}
  for key, _ in pairs(self.cache) do
    table.insert(keys, key)
  end
  return keys
end

-- ============================================================================
-- Configuration
-- ============================================================================

function CacheManager:configure(config)
  if config.max_size then
    self.max_size = config.max_size
  end

  if config.default_ttl then
    self.default_ttl = config.default_ttl
  end

  if config.max_memory_mb then
    self.max_memory_mb = config.max_memory_mb
  end

  if config.eviction_policy then
    self.eviction_policy = config.eviction_policy
  end

  if config.cleanup_interval then
    self.cleanup_interval = config.cleanup_interval
    -- Restart cleanup timer with new interval
    self:stop_cleanup_timer()
    self:start_cleanup_timer()
  end
end

-- ============================================================================
-- Cleanup
-- ============================================================================

function CacheManager:shutdown()
  self:stop_cleanup_timer()
  self:clear()
  Utils.log("🔌 Cache manager shutdown")
end

return CacheManager


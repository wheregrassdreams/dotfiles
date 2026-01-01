-- orbital/client/providers/interfaces/filesystem.lua
-- FileSystemInterface - File and directory operations

local FileSystemInterface = {}

-- Interface definition with method signatures
FileSystemInterface.methods = {
  -- File operations
  "read_file",        -- (path, callback) -> (success, content_or_error)
  "write_file",       -- (path, content, callback) -> (success, message)
  "delete_file",      -- (path, callback) -> (success, message) 
  "copy_file",        -- (src, dest, callback) -> (success, message)
  "move_file",        -- (src, dest, callback) -> (success, message)
  
  -- Directory operations  
  "list_files",       -- (path, callback) -> (success, items_or_error)
  "create_dir",       -- (path, callback) -> (success, message)
  "delete_dir",       -- (path, callback) -> (success, message)
  "get_cwd",          -- (callback) -> (success, path_or_error)
  "change_dir",       -- (path, callback) -> (success, message)
  
  -- File watching (future)
  "watch_file",       -- (path, callback) -> (success, watcher_id)
  "unwatch_file",     -- (watcher_id, callback) -> (success, message)
}

-- Interface requirements documentation
FileSystemInterface.requirements = {
  description = "Provides file and directory operations",
  async = true,
  callback_pattern = "Node.js style: function(success, result_or_error)",
  
  methods = {
    read_file = {
      description = "Read file contents",
      params = {"path (string)", "callback (function)"},
      callback = {"success (boolean)", "content (string) or error (string)"}
    },
    write_file = {
      description = "Write content to file", 
      params = {"path (string)", "content (string)", "callback (function)"},
      callback = {"success (boolean)", "message (string)"}
    },
    list_files = {
      description = "List files in directory",
      params = {"path (string)", "callback (function)"},
      callback = {"success (boolean)", "items (table) or error (string)"}
    },
    get_cwd = {
      description = "Get current working directory",
      params = {"callback (function)"},
      callback = {"success (boolean)", "path (string) or error (string)"}
    },
    change_dir = {
      description = "Change current working directory",
      params = {"path (string)", "callback (function)"},
      callback = {"success (boolean)", "message (string)"}
    }
  }
}

-- Utility function to check if provider implements this interface
function FileSystemInterface.check_implementation(provider)
  local missing_methods = {}
  
  for _, method in ipairs(FileSystemInterface.methods) do
    if not provider[method] or type(provider[method]) ~= "function" then
      table.insert(missing_methods, method)
    end
  end
  
  return #missing_methods == 0, missing_methods
end

-- Mixin helper to add interface checking to provider
function FileSystemInterface.mixin(provider)
  provider.supports_filesystem = true
  provider._filesystem_interface = FileSystemInterface
  
  -- Add capability checking method
  provider.check_filesystem_support = function(self)
    return FileSystemInterface.check_implementation(self)
  end
  
  return provider
end

return FileSystemInterface
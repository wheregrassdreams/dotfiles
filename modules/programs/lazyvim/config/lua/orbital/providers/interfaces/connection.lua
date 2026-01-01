-- orbital/client/providers/interfaces/connection.lua
-- ConnectionInterface - Network connection management

local ConnectionInterface = {}

-- Interface definition with method signatures
ConnectionInterface.methods = {
  -- Connection lifecycle
  "connect",          -- (uri, callback) -> (success, message)
  "disconnect",       -- (callback) -> (success, message)
  "reconnect",        -- (callback) -> (success, message)
  
  -- Connection status
  "is_connected",     -- () -> boolean
  "get_connection_info", -- () -> table
  "get_connection_status", -- () -> string
  
  -- Health checking
  "ping",             -- (callback) -> (success, response_time_ms)
  "health_check",     -- (callback) -> (success, health_info)
  
  -- Connection management
  "set_timeout",      -- (timeout_ms) -> ()
  "get_timeout",      -- () -> timeout_ms
  "reset_connection", -- (callback) -> (success, message)
}

-- Interface requirements documentation
ConnectionInterface.requirements = {
  description = "Provides network connection management and health monitoring",
  async = true,
  callback_pattern = "Node.js style: function(success, result_or_error)",
  
  connection_states = {"disconnected", "connecting", "connected", "reconnecting", "failed"},
  
  methods = {
    connect = {
      description = "Establish connection to remote endpoint",
      params = {"uri (string)", "callback (function)"},
      callback = {"success (boolean)", "message (string)"}
    },
    disconnect = {
      description = "Close connection gracefully",
      params = {"callback (function)"},
      callback = {"success (boolean)", "message (string)"}
    },
    is_connected = {
      description = "Check if currently connected",
      params = {},
      returns = "boolean"
    },
    ping = {
      description = "Test connection responsiveness",
      params = {"callback (function)"},
      callback = {"success (boolean)", "response_time_ms (number) or error (string)"}
    },
    get_connection_info = {
      description = "Get detailed connection information",
      params = {},
      returns = {
        "uri (string)",
        "status (string)",
        "connected_at (number)",
        "last_ping (number)",
        "reconnect_attempts (number)"
      }
    }
  }
}

-- Utility function to check if provider implements this interface
function ConnectionInterface.check_implementation(provider)
  local missing_methods = {}
  
  for _, method in ipairs(ConnectionInterface.methods) do
    if not provider[method] or type(provider[method]) ~= "function" then
      table.insert(missing_methods, method)
    end
  end
  
  return #missing_methods == 0, missing_methods
end

-- Mixin helper to add interface checking to provider
function ConnectionInterface.mixin(provider)
  provider.supports_connection = true
  provider._connection_interface = ConnectionInterface
  
  -- Add capability checking method
  provider.check_connection_support = function(self)
    return ConnectionInterface.check_implementation(self)
  end
  
  -- Initialize connection state
  provider.connection_state = "disconnected"
  provider.connection_info = {
    uri = nil,
    connected_at = nil,
    last_ping = nil,
    reconnect_attempts = 0
  }
  
  return provider
end

return ConnectionInterface
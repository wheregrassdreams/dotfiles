-- orbital/client/providers/interfaces/lsp.lua
-- LSPInterface - Language Server Protocol integration (Future)

local LSPInterface = {}

-- Interface definition with method signatures
LSPInterface.methods = {
  -- LSP server management
  "start_lsp_server", -- (language, config, callback) -> (success, server_id)
  "stop_lsp_server", -- (server_id, callback) -> (success, message)
  "restart_lsp_server", -- (server_id, callback) -> (success, message)
  "get_lsp_servers", -- () -> server_list

  -- LSP requests
  "lsp_request", -- (server_id, method, params, callback) -> (success, result)
  "lsp_notify", -- (server_id, method, params) -> ()
  "lsp_bulk_request", -- (requests, callback) -> (success, results)

  -- LSP capabilities
  "get_lsp_capabilities", -- (server_id) -> capabilities
  "get_server_info", -- (server_id) -> server_info
  "is_server_ready", -- (server_id) -> boolean

  -- Document management
  "open_document", -- (server_id, uri, content, callback) -> (success, message)
  "close_document", -- (server_id, uri, callback) -> (success, message)
  "sync_document", -- (server_id, uri, changes, callback) -> (success, message)
}

-- Interface requirements documentation
LSPInterface.requirements = {
  description = "Provides Language Server Protocol integration for distributed code intelligence",
  async = true,
  callback_pattern = "Node.js style: function(success, result_or_error)",
  future = true,

  server_states = { "starting", "ready", "error", "stopped" },

  methods = {
    start_lsp_server = {
      description = "Start LSP server for specified language",
      params = { "language (string)", "config (table)", "callback (function)" },
      callback = { "success (boolean)", "server_id (string) or error (string)" },
    },
    lsp_request = {
      description = "Send LSP request to server",
      params = { "server_id (string)", "method (string)", "params (table)", "callback (function)" },
      callback = { "success (boolean)", "result (table) or error (string)" },
    },
    get_lsp_capabilities = {
      description = "Get server capabilities",
      params = { "server_id (string)" },
      returns = {
        "completion (boolean)",
        "hover (boolean)",
        "signature_help (boolean)",
        "definition (boolean)",
        "references (boolean)",
        "formatting (boolean)",
      },
    },
  },

  common_methods = {
    "textDocument/completion",
    "textDocument/hover",
    "textDocument/definition",
    "textDocument/references",
    "textDocument/formatting",
    "textDocument/diagnostics",
  },
}

-- Utility function to check if provider implements this interface
function LSPInterface.check_implementation(provider)
  local missing_methods = {}

  for _, method in ipairs(LSPInterface.methods) do
    if not provider[method] or type(provider[method]) ~= "function" then
      table.insert(missing_methods, method)
    end
  end

  return #missing_methods == 0, missing_methods
end

-- Mixin helper to add interface checking to provider
function LSPInterface.mixin(provider)
  provider.supports_lsp = true
  provider._lsp_interface = LSPInterface

  -- Add capability checking method
  provider.check_lsp_support = function(self)
    return LSPInterface.check_implementation(self)
  end

  -- Initialize LSP state
  provider.lsp_servers = {}
  provider.lsp_documents = {}

  return provider
end

return LSPInterface


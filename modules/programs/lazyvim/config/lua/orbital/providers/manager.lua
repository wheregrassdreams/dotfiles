-- orbital/client/backend_manager.lua
-- Interface-Based Provider Registry and Management

local M = {}

-- Import interface-based providers
local LocalProvider = require("orbital.providers.local.init")
local RemoteProvider = require("orbital.client.providers.remote")

-- State
M.current_provider = nil
M.providers = {}
M.provider_registry = {}

-- Logging function
local function log(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify("[Orbital] " .. msg, level)
end

-- ============================================================================
-- Interface-Based Provider Registry
-- ============================================================================

function M.register_providers()
  -- Register interface-based providers
  M.providers.loc = LocalProvider
  M.providers.orbital = RemoteProvider  -- orbital:// URI scheme
  
  -- Register provider capabilities
  M.provider_registry = {
    loc = {
      class = LocalProvider,
      interfaces = {"filesystem", "command"},
      uri_schemes = {"local"},
      description = "Local filesystem and command execution"
    },
    orbital = {
      class = RemoteProvider,
      interfaces = {"filesystem", "connection", "command", "lsp"},
      uri_schemes = {"orbital"},
      description = "Remote Neovim server via RPC (all interfaces)"
    }
  }
  
  log("✅ Interface-based providers registered:")
  for scheme, info in pairs(M.provider_registry) do
    log("  " .. scheme .. "://  (" .. table.concat(info.interfaces, ", ") .. ")")
  end
end

-- ============================================================================
-- Provider Discovery and Capabilities
-- ============================================================================

function M.get_provider_by_capability(interface_name)
  local capable_providers = {}
  
  for scheme, info in pairs(M.provider_registry) do
    for _, interface in ipairs(info.interfaces) do
      if interface == interface_name then
        table.insert(capable_providers, {
          scheme = scheme,
          class = info.class,
          description = info.description
        })
        break
      end
    end
  end
  
  return capable_providers
end

function M.list_provider_capabilities()
  local capabilities = {}
  
  for scheme, info in pairs(M.provider_registry) do
    capabilities[scheme] = {
      interfaces = info.interfaces,
      description = info.description,
      uri_schemes = info.uri_schemes
    }
  end
  
  return capabilities
end

function M.validate_provider_interfaces(provider)
  if not provider then
    return false, "No provider specified"
  end
  
  local all_valid, validation_results = provider:validate_all_interfaces()
  
  if not all_valid then
    local issues = {}
    for interface, result in pairs(validation_results) do
      if not result.valid then
        table.insert(issues, interface .. ": " .. table.concat(result.missing, ", "))
      end
    end
    return false, "Interface validation failed: " .. table.concat(issues, "; ")
  end
  
  return true, "All interfaces valid"
end

-- ============================================================================
-- Provider Creation and Management
-- ============================================================================

function M.create_provider(uri)
  local scheme = uri:match("^(%w+)://")

  if not scheme then
    error("Invalid provider URI. Must include scheme (local://, orbital://, etc.)")
  end

  local provider_class = M.providers[scheme]
  if not provider_class then
    local available = vim.tbl_keys(M.providers)
    table.sort(available)
    error("Unsupported provider: " .. scheme .. ". Available: " .. table.concat(available, ", "))
  end

  local provider = provider_class.new(uri)
  
  -- Validate interfaces after creation
  local valid, error_msg = M.validate_provider_interfaces(provider)
  if not valid then
    log("⚠️ Provider interface validation failed: " .. error_msg, vim.log.levels.WARN)
  end

  return provider
end

function M.switch_provider(uri, on_ready_callback)
  -- Cleanup current provider
  if M.current_provider then
    if M.current_provider.disconnect then
      M.current_provider:disconnect()
    end
  end

  -- Create new provider
  M.current_provider = M.create_provider(uri)
  
  log("🔄 Switching to " .. M.current_provider.type .. " provider...")
  log("📋 Supported interfaces: " .. table.concat(M.current_provider:get_supported_interfaces(), ", "))

  -- Connect based on provider capabilities
  if M.current_provider:supports_interface("connection") then
    -- Provider needs explicit connection
    M.current_provider:connect(uri, function(success, message)
      if success then
        log("✅ Connected to " .. M.current_provider.type .. " provider")
        M.notify_provider_ready(uri, on_ready_callback)
      else
        log("❌ Failed to connect: " .. message, vim.log.levels.ERROR)
        if on_ready_callback then
          on_ready_callback(nil, message)
        end
      end
    end)
  else
    -- Provider connects automatically (like local provider)
    if M.current_provider.connect then
      M.current_provider:connect(uri)
    end
    log("✅ Switched to " .. M.current_provider.type .. " provider")
    M.notify_provider_ready(uri, on_ready_callback)
  end
end

function M.notify_provider_ready(uri, callback)
  -- Trigger event for integrations
  vim.api.nvim_exec_autocmds("User", {
    pattern = "OrbitalBackendChanged",
    data = { backend = M.current_provider },
  })

  -- Notify integrations about backend change (with error handling)
  local neotree_integration = nil
  pcall(function()
    neotree_integration = require("orbital.integrations.neotree")
  end)

  if neotree_integration and neotree_integration.on_backend_changed then
    local ok, err = pcall(neotree_integration.on_backend_changed, M.current_provider)
    if not ok then
      log("Neo-tree integration notification failed: " .. tostring(err), vim.log.levels.WARN)
    end
  end

  -- Call user callback if provided
  if callback then
    callback(M.current_provider)
  end
end

-- ============================================================================
-- Status and Information
-- ============================================================================

function M.get_status()
  local status = {
    current_provider = M.current_provider,
    available_providers = vim.tbl_keys(M.providers),
    provider_registry = M.provider_registry,
  }

  if M.current_provider then
    -- Get full provider capabilities
    status.provider_info = M.current_provider:get_capabilities()
    
    -- Add connection info if provider supports it
    if M.current_provider:supports_interface("connection") then
      status.connection_info = M.current_provider:get_connection_info()
    end
  else
    status.provider_info = {
      message = "No active provider"
    }
  end

  return status
end

function M.get_provider_completions(arg_lead)
  local schemes = vim.tbl_keys(M.providers)
  local completions = {}
  for _, scheme in ipairs(schemes) do
    if scheme:find(arg_lead, 1, true) == 1 then
      table.insert(completions, scheme .. "://")
    end
  end
  return completions
end

-- ============================================================================
-- Interface-Based Operation Routing
-- ============================================================================

function M.can_handle_operation(operation)
  if not M.current_provider then
    return false, "No active provider"
  end
  
  return M.current_provider:can_handle(operation)
end

function M.get_operation_handler(operation)
  if not M.current_provider then
    return nil, "No active provider"
  end
  
  local can_handle, error_msg = M.current_provider:can_handle(operation)
  if not can_handle then
    return nil, error_msg
  end
  
  return M.current_provider[operation], nil
end

-- ============================================================================
-- Initialization
-- ============================================================================

function M.initialize()
  M.register_providers()
  
  -- Default to local provider
  M.switch_provider("local://")
  
  -- Welcome message with available providers
  local available_providers = vim.tbl_keys(M.providers)
  table.sort(available_providers)

  log("🚀 Orbital Interface-Based Provider Manager initialized!")
  log("📦 Available providers: " .. table.concat(available_providers, ", "))
  
  -- Show interface capabilities
  for scheme, info in pairs(M.provider_registry) do
    log("  " .. scheme .. "://  →  " .. info.description)
  end
end

return M

-- init.lua
-- Main entry point for Orbital Unified Backend System with Neovim RPC support

local M = {}

-- Import new modular components
local BackendManager = require("orbital.providers.manager")
local CommandHandlers = require("orbital.command_pipline.handlers")
local Setup = require("orbital.setup")
local CommandPipeline = require("orbital.command_interceptor")

-- ============================================================================
-- Public API - Backward Compatibility
-- ============================================================================

-- Expose backend manager functionality for backward compatibility
M.current_provider = nil
M.server_manager = nil
M.providers = {}
M.intercepted_commands = {}

-- Forward backend manager methods
function M.create_provider(uri)
  return BackendManager.create_provider(uri)
end

function M.switch_provider(uri)
  BackendManager.switch_provider(uri, function(provider)
    -- Update compatibility references
    M.current_provider = provider
    M.server_manager = BackendManager.server_manager
    M.providers = BackendManager.providers
  end)
end

-- Forward command handler methods
function M.handle_edit_command(args)
  return CommandHandlers.handle_edit_command(BackendManager, args)
end

function M.handle_write_command(args)
  return CommandHandlers.handle_write_command(BackendManager, args)
end

function M.handle_write_all_command(args)
  return CommandHandlers.handle_write_all_command(BackendManager, args)
end

function M.handle_cd_command(args)
  return CommandHandlers.handle_cd_command(BackendManager, args)
end

function M.handle_pwd_command(args)
  return CommandHandlers.handle_pwd_command(BackendManager, args)
end

function M.handle_ls_command(args)
  return CommandHandlers.handle_ls_command(BackendManager, args)
end

function M.reload_buffer_from_provider(bufnr, filename)
  return CommandHandlers.reload_buffer_from_provider(BackendManager.current_provider, bufnr, filename)
end

-- Expose intercepted_commands for compatibility
setmetatable(M, {
  __index = function(t, k)
    if k == "intercepted_commands" then
      return CommandHandlers.intercepted_commands
    end
    return rawget(t, k)
  end,
  __newindex = function(t, k, v)
    if k == "intercepted_commands" then
      CommandHandlers.intercepted_commands = v
    else
      rawset(t, k, v)
    end
  end
})

-- ============================================================================
-- Main Setup Function
-- ============================================================================

function M.setup()
  -- Initialize all components
  Setup.setup_all(BackendManager, CommandHandlers, CommandPipeline)
  
  -- Update compatibility references
  M.current_provider = BackendManager.current_provider
  M.server_manager = BackendManager.server_manager
  M.providers = BackendManager.providers
end

-- ============================================================================
-- Notification Functions for Integrations
-- ============================================================================

function M.notify_provider_ready(uri)
  BackendManager.notify_provider_ready(uri)
end

-- Auto-setup when required
M.setup()

return M

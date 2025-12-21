-- orbital/client/providers/interfaces/command.lua
-- CommandInterface - Command execution capabilities

local CommandInterface = {}

-- Interface definition with method signatures
CommandInterface.methods = {
  -- Command execution
  "execute_command",     -- (cmd, args, callback) -> (success, output_or_error)
  "execute_async",       -- (cmd, args, callback) -> (success, job_id)
  "execute_shell",       -- (command_string, callback) -> (success, output_or_error)
  
  -- Job management
  "get_job_status",      -- (job_id) -> status_info
  "cancel_job",          -- (job_id, callback) -> (success, message)
  "wait_for_job",        -- (job_id, callback) -> (success, result)
  
  -- Command history and capabilities
  "get_command_history", -- () -> command_list
  "clear_command_history", -- () -> ()
  "get_shell_info",      -- () -> shell_info
}

-- Interface requirements documentation
CommandInterface.requirements = {
  description = "Provides command execution and job management",
  async = true,
  callback_pattern = "Node.js style: function(success, result_or_error)",
  
  job_states = {"running", "completed", "failed", "cancelled"},
  
  methods = {
    execute_command = {
      description = "Execute command with arguments",
      params = {"cmd (string)", "args (table)", "callback (function)"},
      callback = {"success (boolean)", "output (string) or error (string)"}
    },
    execute_async = {
      description = "Execute command asynchronously",
      params = {"cmd (string)", "args (table)", "callback (function)"},
      callback = {"success (boolean)", "job_id (string) or error (string)"}
    },
    execute_shell = {
      description = "Execute shell command string",
      params = {"command_string (string)", "callback (function)"},
      callback = {"success (boolean)", "output (string) or error (string)"}
    },
    get_job_status = {
      description = "Get status of async job",
      params = {"job_id (string)"},
      returns = {
        "status (string)",
        "exit_code (number)",
        "start_time (number)",
        "end_time (number)"
      }
    },
    get_shell_info = {
      description = "Get shell information",
      params = {},
      returns = {
        "shell (string)",
        "version (string)",
        "working_dir (string)",
        "environment (table)"
      }
    }
  }
}

-- Utility function to check if provider implements this interface
function CommandInterface.check_implementation(provider)
  local missing_methods = {}
  
  for _, method in ipairs(CommandInterface.methods) do
    if not provider[method] or type(provider[method]) ~= "function" then
      table.insert(missing_methods, method)
    end
  end
  
  return #missing_methods == 0, missing_methods
end

-- Mixin helper to add interface checking to provider
function CommandInterface.mixin(provider)
  provider.supports_command = true
  provider._command_interface = CommandInterface
  
  -- Add capability checking method
  provider.check_command_support = function(self)
    return CommandInterface.check_implementation(self)
  end
  
  -- Initialize command state
  provider.command_history = {}
  provider.active_jobs = {}
  
  return provider
end

return CommandInterface
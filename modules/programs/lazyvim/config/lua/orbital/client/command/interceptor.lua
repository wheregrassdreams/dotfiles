-- orbital/init.lua
-- Command Pipeline Interception System

local M = {}

local command_handlers = {}

function M.setup(handlers)
  -- Store the provided handlers
  command_handlers = handlers or {}
  
  -- Set up command line interception
  vim.keymap.set("c", "<CR>", function()
    local full_cmd = vim.fn.getcmdline()
    
    -- Parse command and arguments
    local command, args = full_cmd:match("^(%S+)%s*(.*)$")
    if not command then
      command = full_cmd
      args = ""
    end


    -- TODO: ":" 模式
    
    -- Check if we have a handler for this command
    local handler = command_handlers[command]
    if handler then
      local handled = handler(args)
      if handled then
        -- Command was handled by our backend system
        vim.api.nvim_input("<Esc>")  -- Clear command line
        return
      end
    end
    
    -- Not handled by us, execute normally
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<CR>", true, false, true),
      "n",
      false
    )
  end, { noremap = true })
end

function M.add_handler(command, handler)
  command_handlers[command] = handler
end

function M.remove_handler(command)
  command_handlers[command] = nil
end

function M.get_handlers()
  return command_handlers
end

return M

-- orbital/sources/backend/commands.lua
-- Commands for the backend source

local cc = require("neo-tree.sources.common.commands")
local manager = require("neo-tree.sources.manager")
local utils = require("neo-tree.utils")

local vim = vim

local M = {}

-- Get reference to orbital module
local function get_orbital()
  local ok, orbital = pcall(require, "orbital")
  return ok and orbital or nil
end

-- Open a backend file
M.open = function(state)
  local tree = state.tree
  local node = tree:get_node()

  if not node then
    return
  end

  -- Handle message nodes (empty state, errors, etc.)
  if node.type == "message" then
    if node.extra and node.extra.message then
      vim.notify(node.extra.message, vim.log.levels.INFO)
    end
    return
  end

  -- Only handle files
  if node.type ~= "file" then
    return
  end

  local orbital = get_orbital()
  if not orbital then
    vim.notify("Orbital not available", vim.log.levels.ERROR)
    return
  end

  local file_path = node.extra and node.extra.full_path or node.path
  if not file_path then
    vim.notify("No file path available", vim.log.levels.ERROR)
    return
  end

  -- Close Neo-tree using the manager
  local manager = require("neo-tree.sources.manager")
  manager.close_all()

  -- Use orbital's file opening mechanism
  if orbital.handle_edit_command then
    orbital.handle_edit_command(file_path)
  else
    vim.notify("Orbital file handler not available", vim.log.levels.ERROR)
  end
end

-- Refresh backend files
M.refresh = function(state)
  local orbital = get_orbital()
  if orbital and orbital.current_provider then
    vim.notify("Refreshing backend files...", vim.log.levels.INFO)
  end
  manager.refresh("orbital_backend", state)
end

-- Show backend info
M.show_backend_info = function(state)
  local orbital = get_orbital()
  if not orbital or not orbital.current_provider then
    vim.notify("No backend connected", vim.log.levels.WARN)
    return
  end

  local backend = orbital.current_provider
  local info = {
    "Backend Information:",
    "  Type: " .. backend.type,
    "  URI: " .. backend.uri,
    "  Connected: " .. tostring(backend.connected),
  }

  if backend.host then
    table.insert(info, "  Host: " .. backend.host)
  end

  if backend.user then
    table.insert(info, "  User: " .. backend.user)
  end

  if backend.base_path then
    table.insert(info, "  Base Path: " .. backend.base_path)
  end

  vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end

-- Switch backend
M.switch_backend = function(state)
  local input = vim.fn.input("Enter backend URI (e.g., ssh://user@host/path): ")
  if input and input ~= "" then
    local orbital = get_orbital()
    if orbital and orbital.switch_provider then
      orbital.switch_provider(input)
      -- Refresh will happen automatically via backend change event
    else
      vim.notify("Orbital not available", vim.log.levels.ERROR)
    end
  end
end

-- Create new file through backend
M.add_file = function(state)
  local orbital = get_orbital()
  if not orbital or not orbital.current_provider or not orbital.current_provider.connected then
    vim.notify("No backend connected", vim.log.levels.ERROR)
    return
  end

  local filename = vim.fn.input("New file name: ")
  if filename and filename ~= "" then
    -- Create empty file through backend
    orbital.current_provider:write_file(filename, "", function(success, message)
      if success then
        vim.notify("Created: " .. filename, vim.log.levels.INFO)
        M.refresh(state)

        -- Open the new file
        vim.schedule(function()
          if orbital.handle_edit_command then
            orbital.handle_edit_command(filename)
          end
        end)
      else
        vim.notify("Failed to create file: " .. message, vim.log.levels.ERROR)
      end
    end)
  end
end

-- Delete file through backend
M.delete = function(state)
  local tree = state.tree
  local node = tree:get_node()

  if not node or node.type ~= "file" then
    vim.notify("Select a file to delete", vim.log.levels.WARN)
    return
  end

  local orbital = get_orbital()
  if not orbital or not orbital.current_provider then
    vim.notify("No backend connected", vim.log.levels.ERROR)
    return
  end

  local file_path = node.extra and node.extra.full_path or node.path
  local confirm = vim.fn.confirm("Delete " .. node.name .. "?", "&Yes\n&No", 2)

  if confirm == 1 then
    orbital.current_provider:execute_command({ "rm", file_path }, function(success, output)
      if success then
        vim.notify("Deleted: " .. node.name, vim.log.levels.INFO)
        M.refresh(state)
      else
        vim.notify("Failed to delete: " .. output, vim.log.levels.ERROR)
      end
    end)
  end
end

-- Copy file path to clipboard
M.copy_path = function(state)
  local tree = state.tree
  local node = tree:get_node()

  if not node then
    return
  end

  local path = node.extra and node.extra.full_path or node.path
  if path then
    vim.fn.setreg("+", path)
    vim.notify("Copied path: " .. path, vim.log.levels.INFO)
  end
end

-- Show file details
M.show_file_details = function(state)
  local tree = state.tree
  local node = tree:get_node()

  if not node then
    return
  end

  local details = {
    "File Details:",
    "  Name: " .. node.name,
    "  Type: " .. node.type,
    "  Path: " .. (node.path or "N/A"),
  }

  if node.extra then
    if node.extra.backend_type then
      table.insert(details, "  Backend: " .. node.extra.backend_type)
    end
    if node.extra.backend_uri then
      table.insert(details, "  URI: " .. node.extra.backend_uri)
    end
    if node.extra.full_path then
      table.insert(details, "  Full Path: " .. node.extra.full_path)
    end
  end

  if node.stat then
    table.insert(details, "  Size: " .. (node.stat.size or 0) .. " bytes")
    if node.stat.mtime then
      table.insert(details, "  Modified: " .. os.date("%Y-%m-%d %H:%M:%S", node.stat.mtime.sec))
    end
  end

  vim.notify(table.concat(details, "\n"), vim.log.levels.INFO)
end

-- Add common commands (this includes things like copy, cut, paste, etc.)
cc._add_common_commands(M)

return M

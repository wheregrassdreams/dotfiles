-- orbital/sources/backend/init.lua
-- Neo-tree Backend Source - Proper implementation using Neo-tree's source API

local vim = vim
local renderer = require("neo-tree.ui.renderer")
local manager = require("neo-tree.sources.manager")
local events = require("neo-tree.events")
local utils = require("neo-tree.utils")

local M = {
  name = "orbital_fs",
  display_name = " 🚀 Orbital FS",
}

-- Get reference to orbital module
local function get_orbital()
  local ok, orbital = pcall(require, "orbital")
  return ok and orbital or nil
end

-- Convert backend items to Neo-tree node format
local function backend_files_to_nodes(items, current_backend)
  if not items or #items == 0 then
    return {}
  end

  local nodes = {}

  -- Process structured items from SSH backend
  for _, item in ipairs(items) do
    local node = {
      id = (item.type == "directory" and "dir:" or "file:") .. item.path,
      name = item.name,
      type = item.type,
      path = item.path,
      stat = {
        type = item.type,
        size = item.type == "directory" and 0 or 0,
        mtime = { sec = os.time() },
      },
      extra = {
        backend_type = current_backend.type,
        backend_uri = current_backend.uri,
        is_backend_item = true,
        full_path = item.path,
      },
    }

    table.insert(nodes, node)
  end

  -- Sort: directories first, then files, both alphabetically
  table.sort(nodes, function(a, b)
    if a.type ~= b.type then
      return a.type == "directory"
    end
    return a.name < b.name
  end)

  return nodes
end

-- Get stats for a backend node
M.get_node_stat = function(node)
  if not node or not node.stat then
    return {
      birthtime = { sec = os.time() },
      mtime = { sec = os.time() },
      size = 0,
    }
  end

  return {
    birthtime = { sec = node.stat.mtime.sec },
    mtime = { sec = node.stat.mtime.sec },
    size = node.stat.size or 0,
  }
end

-- Navigate to the given path
M.navigate = function(state, path)
  local orbital = get_orbital()

  -- Ensure state has required properties for Neo-tree renderer
  state = state or {}
  state.path = path or "."
  state.name = M.name

  -- Set default renderers if not present
  if not state.renderers then
    state.renderers = {
      directory = { "icon", "name" },
      file = { "icon", "name" },
      message = { "icon", "message" },
    }
  end

  -- Set default window config if not present
  if not state.window then
    state.window = {
      position = "left",
      width = 30,
    }
  end

  if not orbital or not orbital.current_provider or not orbital.current_provider.connected then
    -- Show empty state with helpful message
    local items = {
      {
        id = "no_backend",
        name = "No backend connected",
        type = "message",
        extra = {
          message = "Use :OrbitalBackend ssh://user@host/path to connect",
        },
      },
    }
    renderer.show_nodes(items, state)
    return
  end

  -- Show loading state
  local loading_items = {
    {
      id = "loading",
      name = "Loading files from " .. orbital.current_provider.type .. " backend...",
      type = "message",
      extra = { message = "Please wait..." },
    },
  }
  renderer.show_nodes(loading_items, state)

  -- Get files from backend
  orbital.current_provider:list_files(state.path, function(success, files)
    vim.schedule(function()
      if not success then
        local error_items = {
          {
            id = "error",
            name = "Failed to load backend files",
            type = "message",
            extra = {
              message = "Error: " .. tostring(files),
              error = true,
            },
          },
        }
        renderer.show_nodes(error_items, state)
        return
      end

      local nodes = backend_files_to_nodes(files, orbital.current_provider)

      if #nodes == 0 then
        local empty_items = {
          {
            id = "empty",
            name = "No files found",
            type = "message",
            extra = {
              message = "Directory is empty or contains only hidden files",
            },
          },
        }
        renderer.show_nodes(empty_items, state)
      else
        renderer.show_nodes(nodes, state)
      end
    end)
  end)
end

-- Setup the source
M.setup = function(config, global_config)
  -- Register our custom stat provider
  utils.register_stat_provider("orbital_backend", M.get_node_stat)

  -- Subscribe to backend change events
  -- We'll trigger refresh when backend changes
  local orbital = get_orbital()
  if orbital then
    -- Hook into backend changes (we'll need to add this to the main orbital module)
    vim.api.nvim_create_autocmd("User", {
      pattern = "OrbitalBackendChanged",
      callback = function()
        manager.refresh(M.name)
      end,
    })
  end
end

return M

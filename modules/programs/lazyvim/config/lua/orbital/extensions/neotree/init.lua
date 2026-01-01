-- orbital/integrations/neotree.lua
-- Simple Neo-tree Integration - Creates virtual directories

local Utils = require("orbital.utils")

local M = {}

-- Reference to the main orbital module
local orbital = nil

-- Create a virtual directory structure for Neo-tree
function M.create_virtual_fs()
  if not orbital or not orbital.current_backend or not orbital.current_backend.connected then
    return
  end

  local backend_type = orbital.current_backend.type
  local virtual_root = "/tmp/orbital_" .. backend_type .. "_" .. os.time()

  -- Create the virtual directory
  vim.fn.mkdir(virtual_root, "p")

  -- Get files from backend and create symlinks/placeholders
  orbital.current_backend:list_files(".", function(success, files)
    if not success then
      Utils.log("Failed to get backend files: " .. files, vim.log.levels.ERROR)
      return
    end

    -- Create placeholder files that Neo-tree can see
    for _, file in ipairs(files) do
      local virtual_path = virtual_root .. "/" .. file:gsub("/", "_") -- Flatten structure for simplicity
      local dir = vim.fn.fnamemodify(virtual_path, ":h")
      vim.fn.mkdir(dir, "p")

      -- Create empty placeholder file
      local placeholder_file = io.open(virtual_path, "w")
      if placeholder_file then
        placeholder_file:write("# Orbital Backend File: " .. file .. "\n")
        placeholder_file:write("# Backend: " .. orbital.current_backend.uri .. "\n")
        placeholder_file:write("# This is a placeholder - real content loaded when opened\n")
        placeholder_file:close()
      end
    end

    -- Open Neo-tree pointing to virtual directory
    vim.schedule(function()
      vim.cmd("Neotree " .. virtual_root)
      Utils.log("Neo-tree opened with " .. #files .. " backend files")
      Utils.log("Virtual directory: " .. virtual_root)
    end)
  end)

  return virtual_root
end

-- Much simpler approach: just create commands that work
function M.setup(orbital_module)
  orbital = orbital_module

  Utils.log("Setting up simple Neo-tree integration")

  -- Command to open Neo-tree with backend files
  vim.api.nvim_create_user_command("OrbitalTree", function()
    if not orbital or not orbital.current_backend or not orbital.current_backend.connected then
      Utils.log("No active backend", vim.log.levels.ERROR)
      return
    end

    if orbital.current_backend.type == "file" then
      -- For file backend, just use normal Neo-tree
      vim.cmd("Neotree")
    else
      -- For other backends, create virtual filesystem
      M.create_virtual_fs()
    end
  end, { desc = "Open Neo-tree with current backend files" })

  -- Enhanced file browser in a buffer (the reliable option)
  vim.api.nvim_create_user_command("OrbitalFiles", function()
    M.show_backend_files()
  end, { desc = "Show backend files in a buffer" })

  -- Set up file interception for placeholder files
  M.setup_placeholder_interception()

  Utils.log("✓ Simple Neo-tree integration ready!")
  Utils.log("Commands: :OrbitalTree, :OrbitalFiles")

  return true
end

-- Intercept opening of placeholder files
function M.setup_placeholder_interception()
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("OrbitalPlaceholder", { clear = true }),
    callback = function(args)
      local filepath = vim.api.nvim_buf_get_name(args.buf)

      -- Check if this is one of our placeholder files
      if filepath:match("/tmp/orbital_") then
        -- Read the placeholder to get the real file path
        local lines = vim.fn.readfile(filepath)
        for _, line in ipairs(lines) do
          local real_path = line:match("# Orbital Backend File: (.+)")
          if real_path then
            Utils.log("Opening real backend file: " .. real_path)

            -- Clear the buffer and load real content
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, {})

            -- Load through orbital
            if orbital and orbital.handle_edit_command then
              orbital.current_backend:read_file(real_path, function(success, content)
                if success then
                  local real_lines = vim.split(content, "\n", { trimempty = false })
                  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, real_lines)
                  vim.api.nvim_buf_set_name(args.buf, "[" .. orbital.current_backend.type .. "] " .. real_path)
                  vim.api.nvim_buf_set_option(args.buf, "modified", false)

                  -- Set up for saving through backend
                  orbital.intercepted_commands[args.buf] = {
                    backend = orbital.current_backend,
                    filename = real_path,
                  }
                else
                  vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, { "Error loading file: " .. content })
                end
              end)
            end

            return true
          end
        end
      end

      return false
    end,
  })
end

-- Enhanced file browser (the reliable fallback)
function M.show_backend_files()
  if not orbital or not orbital.current_backend or not orbital.current_backend.connected then
    Utils.log("No active backend connected", vim.log.levels.ERROR)
    return
  end

  Utils.log("Loading backend file browser...")
  Utils.log("Backend type: " .. orbital.current_backend.type)
  Utils.log("Backend URI: " .. orbital.current_backend.uri)

  orbital.current_backend:list_files(".", function(success, files)
    Utils.log("Backend list_files callback - success: " .. tostring(success))

    if not success then
      Utils.log("Failed to list files: " .. tostring(files), vim.log.levels.ERROR)
      -- Show error in browser
      M.show_error_browser("Failed to list files: " .. tostring(files))
      return
    end

    Utils.log("Files received: " .. vim.inspect(files))
    Utils.log("Number of files: " .. #files)

    -- Create a new buffer for file listing
    local bufnr = vim.api.nvim_create_buf(false, true) -- unlisted, scratch buffer

    -- Prepare file list content
    local lines = {
      "🚀 Orbital Backend File Browser",
      "Backend: " .. orbital.current_backend.uri .. " (" .. orbital.current_backend.type .. ")",
      "=" .. string.rep("=", 60),
      "",
      "📋 Commands:",
      "  <Enter> or <Space>  - Open file",
      "  o                  - Open file",
      "  r                  - Refresh list",
      "  q                  - Close browser",
      "",
      "📁 Files (" .. #files .. " total):",
      "" .. string.rep("-", 40),
    }

    -- Add files to the list with better formatting
    for i, file in ipairs(files) do
      local icon = M.get_file_icon(file)
      table.insert(lines, string.format("  %s %3d. %s", icon, i, file))
      Utils.log("Added file " .. i .. ": " .. file)
    end

    if #files == 0 then
      table.insert(lines, "  (no files found)")
      table.insert(lines, "")
      table.insert(lines, "Debug info:")
      table.insert(lines, "  Backend connected: " .. tostring(orbital.current_backend.connected))
      table.insert(lines, "  Backend type: " .. orbital.current_backend.type)
      table.insert(lines, "  Base path: " .. (orbital.current_backend.base_path or "unknown"))
    end

    -- Set buffer content
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    -- Create unique buffer name to avoid conflicts
    local buffer_name = "[Orbital Browser] " .. orbital.current_backend.type .. "_" .. os.time()
    vim.api.nvim_buf_set_name(bufnr, buffer_name)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(bufnr, "filetype", "orbital-browser")

    -- Open in a split
    vim.cmd("split")
    vim.api.nvim_set_current_buf(bufnr)

    -- Set up keymaps for this buffer
    local opts = { buffer = bufnr, noremap = true, silent = true }

    vim.keymap.set("n", "<CR>", function()
      M.open_file_under_cursor(files)
    end, opts)
    vim.keymap.set("n", "<Space>", function()
      M.open_file_under_cursor(files)
    end, opts)
    vim.keymap.set("n", "o", function()
      M.open_file_under_cursor(files)
    end, opts)
    vim.keymap.set("n", "<2-LeftMouse>", function()
      M.open_file_under_cursor(files)
    end, opts)

    vim.keymap.set("n", "q", function()
      vim.cmd("close")
    end, opts)
    vim.keymap.set("n", "r", function()
      vim.cmd("close")
      M.show_backend_files() -- Refresh
    end, opts)

    -- Test the backend manually with a simpler command
    vim.keymap.set("n", "t", function()
      Utils.log("Testing backend with simple ls command...")
      orbital.current_backend:execute_command({ "ls", "-la" }, function(success, output)
        Utils.log("ls -la result: " .. tostring(success))
        Utils.log("ls -la output: " .. tostring(output))
      end)
    end, opts)

    -- Position cursor on first file
    vim.api.nvim_win_set_cursor(0, { 13, 0 }) -- Line 13 is where files start

    Utils.log("✓ Backend file browser opened (" .. #files .. " files)")
  end)
end

function M.show_error_browser(error_msg)
  -- Create a buffer to show the error and debug info
  local bufnr = vim.api.nvim_create_buf(false, true)

  local lines = {
    "❌ Orbital Backend Error",
    "=" .. string.rep("=", 40),
    "",
    "Error: " .. error_msg,
    "",
    "Debug Information:",
    "  Backend connected: " .. tostring(orbital.current_backend.connected),
    "  Backend type: " .. orbital.current_backend.type,
    "  Backend URI: " .. orbital.current_backend.uri,
  }

  if orbital.current_backend.base_path then
    table.insert(lines, "  Base path: " .. orbital.current_backend.base_path)
  end

  if orbital.current_backend.host then
    table.insert(lines, "  Host: " .. orbital.current_backend.host)
  end

  if orbital.current_backend.user then
    table.insert(lines, "  User: " .. orbital.current_backend.user)
  end

  table.insert(lines, "")
  table.insert(lines, "Troubleshooting:")
  table.insert(
    lines,
    "  1. Check if directory exists: ssh "
      .. (orbital.current_backend.user or "user")
      .. "@"
      .. (orbital.current_backend.host or "host")
      .. ' "ls -la '
      .. (orbital.current_backend.base_path or "/")
      .. '"'
  )
  table.insert(
    lines,
    "  2. Try a different path like: :OrbitalBackend ssh://"
      .. (orbital.current_backend.user or "user")
      .. "@"
      .. (orbital.current_backend.host or "host")
      .. ":/home/"
      .. (orbital.current_backend.user or "user")
  )
  table.insert(lines, "")
  table.insert(lines, "Press 't' to test basic connection")
  table.insert(lines, "Press 'q' to close")

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Create unique buffer name
  local buffer_name = "[Orbital Error] " .. os.time()
  vim.api.nvim_buf_set_name(bufnr, buffer_name)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")

  vim.cmd("split")
  vim.api.nvim_set_current_buf(bufnr)

  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("n", "q", function()
    vim.cmd("close")
  end, opts)
  vim.keymap.set("n", "t", function()
    Utils.log("Testing basic connection...")
    orbital.current_backend:execute_command({ "pwd" }, function(success, output)
      Utils.log("pwd result: " .. tostring(success) .. " - " .. tostring(output))
    end)
    orbital.current_backend:execute_command(
      { "ls", "-la", orbital.current_backend.base_path },
      function(success, output)
        Utils.log(
          "ls -la "
            .. orbital.current_backend.base_path
            .. " result: "
            .. tostring(success)
            .. " - "
            .. tostring(output)
        )
      end
    )
  end, opts)
end

function M.get_file_icon(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then
    return "📄"
  end

  local icons = {
    lua = "🌙",
    py = "🐍",
    js = "📜",
    ts = "📘",
    json = "🔧",
    md = "📝",
    txt = "📄",
    sh = "⚡",
    yml = "⚙️",
    yaml = "⚙️",
    xml = "📋",
    html = "🌐",
    css = "🎨",
    go = "🐹",
    rs = "🦀",
    c = "⚙️",
    cpp = "⚙️",
    java = "☕",
    php = "🐘",
  }

  return icons[ext:lower()] or "📄"
end

function M.open_file_under_cursor(files)
  local line = vim.api.nvim_get_current_line()
  local file_num = line:match("%s*%S+%s*(%d+)%.")

  if file_num then
    local file_index = tonumber(file_num)
    if file_index and files[file_index] then
      local filename = files[file_index]
      Utils.log("Opening file: " .. filename)

      -- Close the file browser
      vim.cmd("close")

      -- Open the file using orbital
      if orbital and orbital.handle_edit_command then
        orbital.handle_edit_command(filename)
      end
    end
  end
end

-- Simple backend change notification
function M.on_backend_changed(new_backend)
  Utils.log("Backend changed to: " .. (new_backend.type or "unknown"))
  Utils.log("Use :OrbitalTree or :OrbitalFiles to browse files")
end

return M

-- orbital/sources/backend/components.lua
-- Custom components for the backend source

local highlights = require("neo-tree.ui.highlights")
local common = require("neo-tree.sources.common.components")

local M = {}

-- Backend type indicator component
M.backend_type = function(config, node, state)
  if not node.extra or not node.extra.backend_type then
    return ""
  end
  
  local backend_icons = {
    file = "💻",
    ssh = "🌐", 
    docker = "🐳",
    s3 = "☁️"
  }
  
  local icon = backend_icons[node.extra.backend_type] or "🔗"
  local highlight = config.highlight or highlights.DIM_TEXT
  
  return {
    text = icon .. " ",
    highlight = highlight,
  }
end

-- Custom message component for empty states
M.message = function(config, node, state)
  if node.type ~= "message" then
    return ""
  end
  
  local text = node.extra.message or node.name
  local highlight = highlights.DIM_TEXT
  
  if node.extra.error then
    highlight = highlights.DIAGNOSTIC_ERROR
  end
  
  return {
    text = text,
    highlight = highlight,
  }
end

-- Enhanced icon component that shows backend status
M.icon = function(config, node, state)
  local icon = config.default or " "
  local padding = config.padding or " "
  local highlight = config.highlight or highlights.FILE_ICON
  
  if node.type == "message" then
    if node.extra and node.extra.error then
      icon = "❌"
      highlight = highlights.DIAGNOSTIC_ERROR
    else
      icon = "ℹ️"
      highlight = highlights.DIM_TEXT
    end
  elseif node.type == "directory" then
    highlight = highlights.DIRECTORY_ICON
    if node:is_expanded() then
      icon = config.folder_open or "📂"
    else
      icon = config.folder_closed or "📁"
    end
  elseif node.type == "file" then
    -- Try to use nvim-web-devicons first
    local success, web_devicons = pcall(require, "nvim-web-devicons")
    if success then
      local devicon, hl = web_devicons.get_icon(node.name, node.ext)
      if devicon then
        icon = devicon
        highlight = hl or highlight
      else
        -- Fallback to our custom icons
        icon = M.get_file_icon(node.name)
      end
    else
      -- Use our custom file type icons
      icon = M.get_file_icon(node.name)
    end
  end
  
  return {
    text = icon .. padding,
    highlight = highlight,
  }
end

-- Helper function for file icons
M.get_file_icon = function(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then 
    return "📄" 
  end
  
  local icons = {
    -- Programming languages
    lua = "🌙",
    py = "🐍",
    js = "💛", 
    jsx = "⚛️",
    ts = "🔷",
    tsx = "⚛️",
    java = "☕",
    c = "🔧",
    cpp = "🔧",
    cc = "🔧",
    go = "🐹",
    rs = "🦀",
    php = "🐘",
    rb = "💎",
    swift = "🐦",
    kt = "🟣",
    scala = "🔴",
    
    -- Web technologies  
    html = "🌐",
    htm = "🌐",
    css = "🎨",
    scss = "🎨",
    sass = "🎨",
    less = "🎨",
    
    -- Config files
    json = "🔧",
    yaml = "⚙️",
    yml = "⚙️",
    toml = "⚙️",
    ini = "⚙️",
    conf = "⚙️",
    config = "⚙️",
    
    -- Documentation
    md = "📝",
    txt = "📄",
    rst = "📄",
    org = "📄",
    
    -- Scripts
    sh = "⚡",
    bash = "⚡",
    zsh = "⚡",
    fish = "🐟",
    ps1 = "💙",
    bat = "🦇",
    cmd = "💻",
    
    -- Data files
    csv = "📊",
    tsv = "📊", 
    xml = "📋",
    sql = "🗃️",
    db = "🗃️",
    sqlite = "🗃️",
    
    -- Images
    png = "🖼️",
    jpg = "🖼️",
    jpeg = "🖼️", 
    gif = "🖼️",
    svg = "🎨",
    ico = "🖼️",
    
    -- Archives
    zip = "📦",
    tar = "📦",
    gz = "📦",
    rar = "📦",
    ["7z"] = "📦",
    
    -- Others
    pdf = "📕",
    log = "📜",
    lock = "🔒",
    key = "🔑",
    pem = "🔑",
    crt = "🔒",
    env = "🌍"
  }
  
  return icons[ext:lower()] or "📄"
end

-- Enhanced name component with clean display
M.name = function(config, node, state)
  local highlight = config.highlight or highlights.FILE_NAME
  local text = node.name
  
  if node.type == "directory" then
    highlight = highlights.DIRECTORY_NAME
  elseif node.type == "message" then
    highlight = node.extra and node.extra.error and highlights.DIAGNOSTIC_ERROR or highlights.DIM_TEXT
  end
  
  if node:get_depth() == 1 then
    highlight = highlights.ROOT_NAME
  end
  
  -- Don't add backend indicator to name - keep it clean
  -- The backend info is shown in the Neo-tree tab/source name
  
  return {
    text = text,
    highlight = highlight,
  }
end

-- File size component (placeholder since we don't have real sizes from backend)
M.size = function(config, node, state)
  if node.type ~= "file" or not node.stat then
    return ""
  end
  
  local size = node.stat.size or 0
  if size == 0 then
    return {
      text = "",
      highlight = highlights.DIM_TEXT
    }
  end
  
  -- Format file size
  local function format_size(bytes)
    if bytes < 1024 then
      return bytes .. "B"
    elseif bytes < 1024 * 1024 then
      return string.format("%.1fK", bytes / 1024)
    elseif bytes < 1024 * 1024 * 1024 then
      return string.format("%.1fM", bytes / (1024 * 1024))
    else
      return string.format("%.1fG", bytes / (1024 * 1024 * 1024))
    end
  end
  
  return {
    text = " " .. format_size(size),
    highlight = highlights.DIM_TEXT,
  }
end

-- Last modified time component
M.last_modified = function(config, node, state)
  if not node.stat or not node.stat.mtime then
    return ""
  end
  
  local mtime = node.stat.mtime.sec
  local now = os.time()
  local diff = now - mtime
  
  local time_str
  if diff < 60 then
    time_str = "now"
  elseif diff < 3600 then
    time_str = math.floor(diff / 60) .. "m"
  elseif diff < 86400 then
    time_str = math.floor(diff / 3600) .. "h"
  elseif diff < 2592000 then
    time_str = math.floor(diff / 86400) .. "d"
  else
    time_str = os.date("%b %d", mtime)
  end
  
  return {
    text = " " .. time_str,
    highlight = highlights.DIM_TEXT,
  }
end

return vim.tbl_deep_extend("force", common, M)

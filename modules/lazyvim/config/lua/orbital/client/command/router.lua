-- ============================================================================
-- Command Router
-- ============================================================================

local M = {}

function M.register_handlers(backend_manager)
  return {
    edit = function(args) return M.handle_edit_command(backend_manager, args) end,
    e = function(args) return M.handle_edit_command(backend_manager, args) end,
    write = function(args) return M.handle_write_command(backend_manager, args) end,
    w = function(args) return M.handle_write_command(backend_manager, args) end,
    wa = function(args) return M.handle_write_all_command(backend_manager, args) end,
    wq = function(args) return M.handle_wq_command(backend_manager, args) end,
    cd = function(args) return M.handle_cd_command(backend_manager, args) end,
    pwd = function(args) return M.handle_pwd_command(backend_manager, args) end,
    ls = function(args) return M.handle_ls_command(backend_manager, args) end,
  }
end

return

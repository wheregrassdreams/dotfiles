
local M = {}
function M.setup_autocommands(command_handlers, provider_manager)
  local group = vim.api.nvim_create_augroup("OrbitalUnified", { clear = true })

  -- Fallback: Intercept write commands via autocmd for non-intercepted cases
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    callback = function(args)
      -- This is a fallback that should rarely be used since we intercept commands
      local buffer_info = command_handlers.get_buffer_info(args.buf)
      if buffer_info then
        -- This is a backend-managed buffer, handle write
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        local content = table.concat(lines, "\n")
        
        buffer_info.provider:write_file(buffer_info.filename, content, function(success, message)
          if success then
            vim.api.nvim_buf_set_option(args.buf, "modified", false)
            log("✓ Saved " .. buffer_info.filename)
          else
            log("Failed to save " .. buffer_info.filename .. ": " .. message, vim.log.levels.ERROR)
          end
        end)
      else
        -- Fallback to default save behavior
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        local name = vim.api.nvim_buf_get_name(args.buf)
        if name ~= "" then
          vim.fn.writefile(lines, name)
          vim.api.nvim_buf_set_option(args.buf, "modified", false)
        end
      end
    end,
  })

  -- Cleanup on buffer delete
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    callback = function(args)
      command_handlers.cleanup_buffer(args.buf)
    end,
  })

  -- Cleanup on Neovim exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      if provider_manager.server_manager then
        log("🔄 Shutting down Neovim RPC server...")
        provider_manager.server_manager:shutdown()
      end
    end,
  })
end


return M

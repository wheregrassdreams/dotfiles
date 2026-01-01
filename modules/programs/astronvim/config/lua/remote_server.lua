----------------------------------------------------------------------
-- remote_server.lua
-- Level 2 Test: handle JSON messages
----------------------------------------------------------------------

local uv = vim.loop
local M = {}

function M.setup(sock_path)
  sock_path = sock_path or "/tmp/nvim-remote.sock"
  os.remove(sock_path)

  local server = uv.new_pipe(false)
  server:bind(sock_path)
  server:listen(128, function(err)
    assert(not err, err)
    local client = uv.new_pipe(false)
    server:accept(client)
    print("[remote] 🔌 Client connected at " .. sock_path)

    client:read_start(function(err2, chunk)
      if err2 then
        print("[remote] ❌ Read error: " .. err2)
        return
      elseif not chunk then
        print "[remote] 🔌 Client disconnected"
        return
      end

      local ok, req = pcall(vim.json.decode, chunk)
      if not ok or not req then
        print("[remote] ⚠️ Invalid JSON: " .. tostring(chunk))
        return
      end

      print("[remote] 📦 Received:", vim.inspect(req))

      if req.method == "echo" and req.params then
        local msg = req.params.msg or "?"
        local resp = {
          type = "response",
          id = req.id,
          result = "echo: " .. msg,
        }
        client:write(vim.json.encode(resp) .. "\n")
      else
        local resp = {
          type = "error",
          id = req.id,
          message = "unknown method: " .. tostring(req.method),
        }
        client:write(vim.json.encode(resp) .. "\n")
      end
    end)
  end)

  print("[remote] 🧩 Listening at " .. sock_path)
end

return M

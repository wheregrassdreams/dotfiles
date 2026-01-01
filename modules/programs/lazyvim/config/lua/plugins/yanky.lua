-- 使用osc52时会导致错误，暂时不使用

return {
  "gbprod/yanky.nvim",
  enabled = false,
  opts = {
    system_clipboard = {
      sync_with_ring = false,
      clipboard_register = nil,
    },
  },
}


local build_cmd = (function()
  if vim.fn.executable("bun") then
    return string.format("bun install")
  end
  if  vim.fn.executable("yarn") then
    return string.format("cd app && yarn install")
  end
  if vim.fn.executable("npm") then
    return string.format("npm install")
  end
end)()


---@type NvPluginSpec
-- return {
--   "iamcco/markdown-preview.nvim",
--   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
--   build = build_cmd,
--   init = function()
--     vim.g.mkdp_filetypes = { "markdown", "Avante" }
--   end,
--   ft = { "markdown"  },
-- }


return {
  'iamcco/markdown-preview.nvim',
  -- keys = { { '<f7>', '<cmd> MarkdownPreviewToggle <CR>' } },
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = 'markdown',
  build = 'cd app && npm install',
  config = function()
    -- FIXME: 用不了
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "markdonw" },
      callback = function()
        vim.api.nvim_buf_set_keymap( 0, "n", "<Leader><Leader>p", "<cmd>MarkdownPreviewToggle<cr>", { noremap = true, silent = true, desc = "Markdown Preview" })
      end,
    })
    -- FIXME: 用不了

    -- vim.api.nvim_exec2(
    --   [[
    --     function MkdpBrowserFn(url)
    --       execute 'silent ! kitty @ launch --dont-take-focus --bias 40 awrit ' . a:url
    --     endfunction
    --   ]],
    --   {}
    -- )
    -- vim.g.mkdp_browserfunc = 'MkdpBrowserFn'

    vim.g.mkdp_theme = 'dark'
    vim.g.mkdp_filetypes = { 'markdown' }
  end,
}

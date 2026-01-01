-- Super powerful color picker/colorizer plugin
return	{
  'uga-rosa/ccc.nvim',
  -- enabled = false,
  -- event = 'FileType', -- 不使用highlighter的话也就没必要了
  keys = {
    { '<Leader><Leader>c', '<cmd>CccPick<CR>', desc = 'Color Picker' },
  },
  opts = {
    highlighter = {
      auto_enable = false, -- TODO: 判断是否使用内置
      lsp = true,
      filetypes = {
        'html',
        'lua',
        'css',
        'scss',
        'sass',
        'less',
        'stylus',
        'javascript',
        'tmux',
        'typescript',
      },
      excludes = { 'lazy', 'mason', 'help', 'neo-tree' },
    },
  },
}

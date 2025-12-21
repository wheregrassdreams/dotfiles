-- Neovim plugin for splitting/joining blocks of code like arrays, hashes, statements, objects, dictionaries, etc.
return {
  'Wansmer/treesj',
  -- enabled = false,
  -- TODO: 屏蔽默认按键
  keys = {
    {
      '<space>=m',
      function () require('treesj').toggle() end,
      mode = { 'n', 'x' },
      desc = "Treejs Toggle",
    },
    {
      '<space>=s',
      function () require('treesj').toggle() end,
      mode = {'n', 'x'},
      desc = "Treejs Split",
    },
    {
      '<space>=j',
      function () require('treesj').toggle() end,
      mode = { 'n', 'x' },
      desc = "Treejs Join",
    },
  },
  dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
  config = function()
    require('treesj').setup({--[[ your config ]]})
  end,
}

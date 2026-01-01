---@type LazySpec
return {
  "folke/todo-comments.nvim",
  optional = true,
  keys = {
    -- { "<leader>ft", function() require("snacks").picker.todo_comments() end, desc = "Todo" },
    {
      "<leader>fT",
      function() require("snacks").picker.todo_comments { keywords = { "TODO", "FIX", "FIXME" } } end,
      desc = "Todo/Fix/Fixme",
    },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
    {
      "<leader>xT",
      "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
      desc = "Todo/Fix/Fixme (Trouble)",
    },
  },
}

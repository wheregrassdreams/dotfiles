return {
  "pogyomo/winresize.nvim",
  event = "VeryLazy",
  config = function ()
    -- 优化window resize逻辑
    local resize = function(win, amt, dir)
      return function()
        require("winresize").resize(win, amt, dir)
      end
    end
    vim.keymap.set("n", "<C-Left>",  resize(0, 2, "left"),  { desc = "Resize windows left" })
    vim.keymap.set("n", "<C-Down>",  resize(0, 1, "down"),  { desc = "Resize windows down" })
    vim.keymap.set("n", "<C-Up>",    resize(0, 1, "up"),    { desc = "Resize windows up" })
    vim.keymap.set("n", "<C-Right>", resize(0, 2, "right"), { desc = "Resize windows right" })
  end

}

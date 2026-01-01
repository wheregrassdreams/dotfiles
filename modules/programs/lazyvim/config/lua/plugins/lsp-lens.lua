return {
  "VidocqH/lsp-lens.nvim",
  event = "LspAttach",
  opts = {
    sections = {
      definition = false,
      references = function(count)
        return "󰌹 References: " .. count
      end,
      implements = function(count)
        return "󰡱 Implements: " .. count
      end,
      git_authors = false,
      -- git_authors = function(latest_author, count)
      --   return " " .. latest_author .. (count - 1 == 0 and "" or (" + " .. count - 1))
      -- end,
    },
  },
  keys = {
    { "<leader>ue", "<cmd>LspLensToggle<cr>", desc = "Toggle Lsp Lens" },
  },
}

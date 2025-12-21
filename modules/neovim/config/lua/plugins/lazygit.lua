return {
    "kdheepak/lazygit.nvim",
    cmd = {"LazyGit"},
    event = "VeryLazy",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Lazygit" },
      -- { "<leader>gr", "<cmd>Telescope lazygit<cr>", desc = "Lazygit Repo" },
    },
    -- lazy = false, -- cannot be lazy to use with telescope
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension "lazygit"
    end,
  }

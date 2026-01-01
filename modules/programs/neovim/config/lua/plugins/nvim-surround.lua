  -- nvim-surround
return {
    "kylechui/nvim-surround",
    version = "å*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  }

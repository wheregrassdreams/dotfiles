-- NOTE: 默认的按键绑定中 "<leader>af" 也就是 AvanteFocus 命令
-- 需要先使用 “<leader>aa” 也就是 AvanteAsk 后才能使用，不然会报错
-- 可能是因为执行 AvanteAsk 后插件才正式激活
-- NOTE: 输入框输入/help

return {
  "yetone/avante.nvim",

  enabled = false,


  -- Default
  -- -- event = "VeryLazy",
  -- lazy = false,

  event = "VeryLazy",


  version = false, -- set this if you want to always pull the latest change

  opts = {
    provider = "copilot",
    copilot = {
      endpoint = "https://api.githubcopilot.com",
      model = "gpt-4o-2024-05-13",
      proxy = nil, -- [protocol://]host[:port] Use this proxy
      allow_insecure = false, -- Allow insecure server connections
      timeout = 30000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 4096,
    },
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o",
      timeout = 30000, -- Timeout in milliseconds
      temperature = 0,
      max_tokens = 4096,
      ["local"] = false,
    },

    -- add any opts here
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  -- config = function ()
  --
  -- end

}

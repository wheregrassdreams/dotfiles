-- TODO: 暂时放一些插件
return {
  {
    "nvim-telescope/telescope-frecency.nvim",
    enabled = false, -- 感觉没用，而且导致退出Neovim时有延迟
    event = "VimEnter",
    config = function()
      require("telescope").load_extension "frecency"
    end,
  },

  -- {
  --   "stevearc/conform.nvim",
  --   event = "BufWritePre", -- uncomment for format on save
  --   opts = require "configs.conform",
  -- },
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    event = "VimEnter", -- 通过<leader>触发太慢了
    config = function()
      dofile(vim.g.base46_cache .. "whichkey")
      local wk = require("which-key")
      wk.add({
        -- { "<leader>c", group = "[C]ode", icon = "" },
       -- { "<leader>c_", hidden = true },
        { "<leader>L",        name  = "Plugins (Lazy)",       icon = { icon = "󰒲 ",                    } },
        { "<leader>K",        name  = "Preview foled maps",   icon = { icon = " ",   color = "white"  } },
        { "<leader>e",        name  = "[E]xplorer",           icon = { icon = "󰥩 ",   color = "yellow" } },
        { "<leader>p",        name  = "[P]aste from history", icon = "󱘣 " },

        { "<leader>|",        name  = "Split Window Right",   icon = { icon = " ",   color = "white" } },
        { "<leader>-",        name  = "Split Window Below",   icon = { icon = " ",   color = "white" } },
        { "<leader>'",        name  = "Close Buffer",         icon = { icon = "❌",   color = "red"   } },
        { "<leader>`",        name  = "Last Buffer ",         icon = { icon = "󰌑 ",   color = "grey"   } },
        { "<leader>;",        name  = "Switch Buffers",       icon = { icon = " ",   color = "grey"   } },

        { "<leader>h",        group = "[H]elp",               icon = { icon = "󰋖",    color = "grey"   } },
        { "<leader>u",        group = "[U]I",                 icon = { icon = " ",   color = "white"  } },
        { "<leader>b",        group = "[B]uffers",            icon = { icon = "󱂬 ",   color = "white"  } },
        { "<leader>f",        group = "[F]ind (Telescope)",   icon = { icon = " ",   color = "orange" } },
        { "<leader>c",        group = "[C]ode (Lsp)",         icon = { icon = " ",   color = "yellow" } },
        { "<leader>d",        group = "[D]ebug",              icon = { icon = " ",   color = "red"    } },
        { "<leader>t",        group = "[T]erminal",           icon = { icon = " ",   color = "black"  } },
        { "<leader>g",        group = "[G]it",                icon = { icon = " ",   color = "red"    } },
        { "<leader>a",        group = "[A]I",                 icon = { icon = "󰚩 "  , color = "grey"   } },
        { "<leader><leader>", group = "More Tools",           icon = { icon = " ",   color = "grey"   } },
        -- { "<leader>d_", hidden = true },
      })
    end,
  },
  -- These are some examples, uncomment them if you want to see them work!

-- Git
	-- {
	-- 	"NeogitOrg/neogit",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		require("rc/pluginconfig/neogit")
	-- 	end,
	-- },
	-- {
	-- 	"akinsho/git-conflict.nvim",
	-- 	event = "VeryLazy",
	-- 	config = true,
	-- },
	-- { "yutkat/convert-git-url.nvim", cmd = { "ConvertGitUrl" } },
	-- {
	-- 	"lewis6991/gitsigns.nvim",
	-- 	event = "VimEnter",
	-- 	config = function()
	-- 		require("rc/pluginconfig/gitsigns")
	-- 	end,
	-- },
	-- {
	-- 	"sindrets/diffview.nvim",
	-- 	event = "VeryLazy",
	-- 	config = function()
	-- 		require("rc/pluginconfig/diffview")
	-- 	end,
	-- },
	--
	-- --------------------------------
	-- -- Git command assistant
	-- -- { "hotwatermorning/auto-git-diff", ft = { "gitrebase" } },
	-- {
	-- 	"yutkat/git-rebase-auto-diff.nvim",
	-- 	ft = { "gitrebase" },
	-- 	config = true,
	-- },
	--
	-- --------------------------------
	-- -- GitHub
	-- {
	-- 	"pwntester/octo.nvim",
	-- 	cmd = { "Octo" }
	-- },

}

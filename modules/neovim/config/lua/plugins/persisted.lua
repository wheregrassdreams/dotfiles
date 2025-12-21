---@type NvPluginSpec
return {
  "olimorris/persisted.nvim",
  enabled = true,
  -- -- event = "BufReadPre",
  -- lazy = false, -- make sure the plugin is always loaded at startup

  -- TODO: for test
  event = "User",

  opts = {
    -- autoload = true, 
    autosave = true,
    use_git_branch = true,
    allowed_dirs = {}, -- Table of dirs that the plugin will start and autoload from

    -- TODO: 需要让persised识别nvim传入的目录参数
    ignored_dirs = {
      -- "~", -- home dir
    }, -- Table of dirs that are ignored for starting and autoloading
    telescope = {
      mappings = { -- Mappings for managing sessions in Telescope
        copy_session = "<C-c>",
        change_branch = "<C-b>",
        delete_session = "<C-d>",
      },
      icons = { -- icons displayed in the Telescope picker
        selected = " ",
        dir = "  ",
        branch = " ",
      },
      should_save = function()
        -- Do not save if the dashboard is the current filetype
        if vim.bo.filetype == "nvdash" then
          return false
        end
        return true
      end,

      -- on_autoload_no_session = function()
      --   vim.notify("No existing session to load.")
      -- end
    },
  },
  config = function(_, opts)
    local persisted = require "persisted"
    -- 没用
    require("telescope").load_extension("persisted")
    persisted.branch = function()
      local branch = vim.fn.systemlist("git branch --show-current")[1]
      return vim.v.shell_error == 0 and branch or nil
    end
    -- vim.keymap.set("n", "<leader>qs", "<cmd>SessionLoad<cr>", { desc = "Restore Session" })
    -- vim.keymap.set("n", "<leader>qS", "<cmd>SessionSelect<cr>",  { desc = "Select Session" })
    -- vim.keymap.set("n", "<leader>ql", "<cmd>SessionLoadLast<cr>", { desc = "Restore Last Session" })
    -- vim.keymap.set("n", "<leader>qd", "<cmd>SessionDelete<cr>",  { desc = "Don't Save Current Session" })

    persisted.setup(opts)
  end,

  keys = {
    { "<leader>qs", "<cmd>SessionLoad<cr>", desc = "Restore Session (cwd)" },
    { "<leader>qS", "<cmd>SessionSelect<cr>", desc = "Select Session" },
    -- FIXME: 报错
    -- { "<leader>qS", "<cmd>Telescope persisted<cr>", desc = "Select Session" },

    { "<leader>ql", "<cmd>SessionLoadLast<cr>", desc = "Restore Last Session" },
    { "<leader>qd", "<cmd>SessionDelete<cr>", desc = "Delete Current Session (and don't save)" },
  },
}


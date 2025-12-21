-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

---@param config {type?:string, args?:string[]|fun():string[]?}
-- local function get_args(config)
--   local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
--   local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]
--
--   config = vim.deepcopy(config)
--   ---@cast args string[]
--   config.args = function()
--     local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
--     if config.type and config.type == "java" then
--       ---@diagnostic disable-next-line: return-type-mismatch
--       return new_args
--     end
--     return require("dap.utils").splitstr(new_args)
--   end
--   return config
-- end

-- TODO: 暂时放着
-- local has_dap_virtual_text, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
-- if not has_dap_virtual_text then
--   return {}
-- end


return {

  'mfussenegger/nvim-dap',

  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',

   "theHamsta/nvim-dap-virtual-text",
  },

  keys = {
    { '<F5>', function() require('dap').continue() end, desc = 'Debug Start/Continue' },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { '<F1>', function() require('dap').step_into() end, desc = 'Debug Step Into' },
    { '<F2>', function() require('dap').step_over() end, desc = 'Debug Step Over'},
    { '<F3>', function() require('dap').step_out() end, desc = 'Debug Step Out', },
    { '<F7>', function() require('dapui').toggle() end, desc = 'Debug See last session result.' },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug UI' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug Toggle Breakpoint', },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = 'Debug Set Breakpoint', },
    -- { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Debug UI Widgets" },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'


    require('mason-nvim-dap').setup {
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause      = ' ',
          play       = ' ',
          step_into  = ' ',
          step_over  = ' ',
          step_out   = ' ',
          step_back  = ' ',
          run_last   = ' ',
          terminate  = ' ',
          disconnect = ' ',
        },
      },
    }

    -- Change breakpoint icons
    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    local dap_virtual_text = require("nvim-dap-virtual-text")

    dap.listeners.after.disconnect["dapui_config"] = function()
      require("dap.repl").close()
      dapui.close()
      dap_virtual_text.refresh()
    end
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_initialized["dapui_config"] = function()
      local api = require "nvim-tree.api"
      local view = require "nvim-tree.view"
      if view.is_visible() then
        api.tree.close()
      end

      for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local bufnr = vim.api.nvim_win_get_buf(winnr)
        if vim.api.nvim_get_option_value("ft", { buf = bufnr }) == "dap-repl" then
          return
        end
      end
      -- dapui:open()
    end

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}

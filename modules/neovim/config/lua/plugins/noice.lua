-- TODO: 去掉NvimTree创建的消息提示
-- TODO: 去掉Lazyvim检测到文件变化时的提示
return {
  "folke/noice.nvim",
  enabled = true,
  event = "VeryLazy",

  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",

  },
  opts = {
    -- add any options here


    presets = {
      -- you can enable a preset by setting it to true, or a table that will override the preset config
      -- you can also add custom presets that you can enable/disable with enabled=true
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = false, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      -- lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    override = {
      -- override the default lsp markdown formatter with Noice
      ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
      -- override the lsp markdown formatter with Noice
      ["vim.lsp.util.stylize_markdown"] = false,
      -- override cmp documentation with Noice (needs the other options to work)
      ["cmp.entry.get_documentation"] = false,
    },

    cmdline = {
      enabled = true, -- enables the Noice cmdline UI
      view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
      opts = {}, -- global options for the cmdline. See section on views
      format = {
        -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
        -- view: (default is cmdline view)
        -- opts: any options passed to the view
        -- icon_hl_group: optional hl_group for the icon
        -- title: set to anything or empty string to hide
        cmdline = { pattern = "^:", icon = " ", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = "  ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = "  ", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = " ", lang = "lua" },
        help = { pattern = "^:%s*he?l?p?%s+", icon = "󰋖" },
        input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
        -- lua = false, -- to disable a format, set to `false`
      },
    },
    messages = {
      -- NOTE: If you enable messages, then the cmdline is enabled automatically.
      -- This is a current Neovim limitation.
      enabled = true, -- enables the Noice messages UI
      view = "notify", -- default view for messages
      view_error = "notify", -- view for errors
      view_warn = "notify", -- view for warnings
      view_history = "messages", -- view for :messages
      view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
    },
    popupmenu = {
      enabled = true, -- enables the Noice popupmenu UI
      ---@type 'nui'|'cmp'
      backend = "nui", -- backend to use to show regular cmdline completions
      -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
      kind_icons = {}, -- set to `false` to disable icons
    },
    -- default options for require('noice').redirect
    -- see the section on Command Redirection
    redirect = {
      view = "popup",
      filter = { event = "msg_show" },
    },
    -- You can add any custom commands below that will be available with `:Noice command`
    commands = {
      history = {
        -- options for the message history that you get with `:Noice`
        view = "split",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
      },
      -- :Noice last
      last = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = {
          any = {
            { event = "notify" },
            { error = true },
            { warning = true },
            { event = "msg_show", kind = { "" } },
            { event = "lsp", kind = "message" },
          },
        },
        filter_opts = { count = 1 },
      },
      -- :Noice errors
      errors = {
        -- options for the message history that you get with `:Noice`
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { error = true },
        filter_opts = { reverse = true },
      },
      all = {
        -- options for the message history that you get with `:Noice`
        view = "split",
        opts = { enter = true, format = "details" },
        filter = {},
      },
    },
    notify = {
      -- Noice can be used as `vim.notify` so you can route any notification like other messages
      -- Notification messages have their level and other properties set.
      -- event is always "notify" and kind can be any log level as a string
      -- The default routes will forward notifications to nvim-notify
      -- Benefit of using Noice for this is the routing and consistent history view
      enabled = true,
      view = "notify",
    },
    lsp = {
      progress = {
        enabled = true,
        -- enabled = false, -- nvchad ui 自带
        -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
        -- See the section on formatting for more details on how to customize.
        format = "lsp_progress",
        format_done = "lsp_progress_done",
        throttle = 1000 / 30, -- frequency to update lsp progress message
        view = "mini", -- defaults
      },
      hover = {
        enabled = false,
        silent = false, -- set to true to not show a message if hover is not available
        view = nil, -- when nil, use defaults from documentation
        opts = {}, -- merged with defaults from documentation
      },
      signature = {
        enabled = false, -- use nvchad UI intergration
        auto_open = {
          enabled = true,
          trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
          luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
          throttle = 50, -- Debounce lsp signature help request by 50ms
        },
        view = nil, -- when nil, use defaults from documentation
        opts = {}, -- merged with defaults from documentation
      },
      message = {
        -- Messages shown by lsp servers
        enabled = true,
        view = "notify",
        opts = {},
      },
      -- defaults for hover and signature help
      documentation = {
        view = "hover",
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
    },
    -- markdown = {
    --   hover = {
    --     ["|(%S-)|"] = vim.cmd.help, -- vim help links
    --     ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
    --   },
    --   highlights = {
    --     ["|%S-|"] = "@text.reference",
    --     ["@%S+"] = "@parameter",
    --     ["^%s*(Parameters:)"] = "@text.title",
    --     ["^%s*(Return:)"] = "@text.title",
    --     ["^%s*(See also:)"] = "@text.title",
    --     ["{%S-}"] = "@parameter",
    --   },
    -- },
    health = {
      checker = true, -- Disable if you don't want health checks to run
    },
    throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
    views = {}, ---@see section on views
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "%d+L, %d+B" },
            { find = "; after #%d+" },
            { find = "; before #%d+" },
          },
        },
        view = "mini",
      },

      -- 来自 https://github.com/BrunoKrugel/dotfiles/blob/master/lua/configs/noice.lua
      {
        filter = {
          event = "msg_show",
          kind = "",
          any = {

            -- Edit
            { find = "%d+ less lines" },
            { find = "%d+ fewer lines" },
            { find = "%d+ more lines" },
            { find = "%d+ change;" },
            { find = "%d+ line less;" },
            { find = "%d+ more lines?;" },
            { find = "%d+ fewer lines;?" },
            { find = '".+" %d+L, %d+B' },
            { find = "%d+ lines yanked" },
            { find = "^Hunk %d+ of %d+$" },
            { find = "%d+L, %d+B$" },
            { find = "^[/?].*" }, -- Searching up/down
            { find = "E486: Pattern not found:" }, -- Searcingh not found
            { find = "%d+ changes?;" }, -- Undoing/redoing
            { find = "%d+ fewer lines" }, -- Deleting multiple lines
            { find = "%d+ more lines" }, -- Undoing deletion of multiple lines
            { find = "%d+ lines " }, -- Performing some other verb on multiple lines
            { find = "Already at newest change" }, -- Redoing
            { find = '"[^"]+" %d+L, %d+B' }, -- Saving

            -- Save
            { find = " bytes written" },

            -- Redo/Undo
            { find = " changes; before #" },
            { find = " changes; after #" },
            { find = "1 change; before #" },
            { find = "1 change; after #" },

            -- Yank
            { find = " lines yanked" },

            -- Move lines
            { find = " lines moved" },
            { find = " lines indented" },

            -- Bulk edit
            { find = " fewer lines" },
            { find = " more lines" },
            { find = "1 more line" },
            { find = "1 line less" },

            -- General messages
            { find = "Already at newest change" }, -- Redoing
            { find = "Already at oldest change" },
            { find = "E21: Cannot make changes, 'modifiable' is off" },
          },
        },

        view = "mini",
        -- opts = { skip = true },
      },

      {
        filter = {
          any = {
            { find = "No information available" },
            { find = "No references found" },
            { find = "No lines in buffer" },
          },
        },
        opts = { skip = true },
      },

    },
    status = {}, --- @see section on statusline components
    format = {}, --- @see section on formatting
  },
  config = function (_, opts)
    if vim.o.filetype == "lazy" then
      vim.cmd([[messages clear]])
    end
    return require("noice").setup(opts)
  end
  -- you can enable a preset for easier configuration
}

-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },
  --
  -- -- == Examples of Overriding Plugins ==
  --
  -- -- customize dashboard options
  -- {
  --   "folke/snacks.nvim",
  --   opts = {
  --     dashboard = {
  --       preset = {
  --         header = table.concat({
  --           " █████  ███████ ████████ ██████   ██████ ",
  --           "██   ██ ██         ██    ██   ██ ██    ██",
  --           "███████ ███████    ██    ██████  ██    ██",
  --           "██   ██      ██    ██    ██   ██ ██    ██",
  --           "██   ██ ███████    ██    ██   ██  ██████ ",
  --           "",
  --           "███    ██ ██    ██ ██ ███    ███",
  --           "████   ██ ██    ██ ██ ████  ████",
  --           "██ ██  ██ ██    ██ ██ ██ ████ ██",
  --           "██  ██ ██  ██  ██  ██ ██  ██  ██",
  --           "██   ████   ████   ██ ██      ██",
  --         }, "\n"),
  --       },
  --     },
  --   },
  -- },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    config = function()
      local actions = require "diffview.actions"

      require("diffview").setup {
        enhanced_diff_hl = true, -- 更好看的 diff 高亮
        view = {
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = true,
          },
          default = {
            winbar_info = true, -- 显示文件名
          },
        },
        keymaps = {
          view = {
            {
              "n",
              "q",
              function()
                actions.close()
                -- 跳回实际文件 buffer
                vim.defer_fn(function() pcall(actions.goto_file_edit) end, 10)
              end,
              { desc = "Close Diffview and return to real file" },
            },
          },
          file_panel = {
            {
              "n",
              "q",
              function()
                vim.cmd "DiffviewClose"
                vim.defer_fn(function() pcall(actions.goto_file_edit) end, 10)
              end,
              { desc = "Close Diffview panel and return to real file" },
            },
          },
          file_history_panel = {
            {
              "n",
              "q",
              function()
                vim.cmd "DiffviewClose"
                vim.defer_fn(function() pcall(actions.goto_file_edit) end, 10)
              end,
              { desc = "Close Diffview history panel and return" },
            },
          },
        },
      }
    end,
  },
  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xjx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },

  {
    "oribarilan/lensline.nvim",
    tag = "1.1.2",
    event = "LspAttach",
    config = function()
      require("lensline").setup {
        -- style = {
        --   placement = "inline",
        --   prefix = "",
        -- },
        style = {
          placement = "inline",
          prefix = "",
          render = "focused", -- or "all" for showing lenses in all functions
        },
      }
    end,
  },

  {
    "mistricky/codesnap.nvim",
    opts = function(plugin, opts)
      opts.save_path = "~/Downloads/"
      opts.has_breadcrumbs = true
      opts.bg_theme = "sea"
      opts.bg_x_padding = 0
      opts.bg_y_padding = 0
      return opts
    end,
  },

  {
    "mistricky/codesnap.nvim",
    build = "make",
    keys = {
      -- { "<leader>@c", "<cmd>'<,'>CodeSnap<cr>", mode = { "x" }, desc = "Save selected code snapshot into clipboard" },
      -- {
      --   "<leader>@s",
      --   "<cmd>'<,'>CodeSnapSave<cr>",
      --   mode = { "x" },
      --   desc = "Save selected code snapshot in ~/Downloads/",
      -- },
      -- -- 修正后的背景切换快捷键
      -- {
      --   "<leader>@b",
      --   function() _G.toggle_codesnap_bg() end,
      --   desc = "Toggle CodeSnap background",
      -- },
    },
    opts = {
      save_path = "~/Downloads/",
      has_breadcrumbs = true,
      bg_theme = "sea",
      -- bg_padding = 0, -- 默认无背景
      bg_x_padding = 0,
      bg_y_padding = 0,
    },
    config = function(_, opts)
      local codesnap = require "codesnap"
      codesnap.setup(opts)

      -- 初始化状态
      local show_bg = false -- 默认无背景（因为bg_padding=0）

      -- 创建全局切换函数
      function _G.toggle_codesnap_bg()
        show_bg = not show_bg
        if show_bg then
          -- 显示背景：使用默认padding值
          codesnap.setup { bg_x_padding = 122, bg_y_padding = 82, bg_theme = opts.bg_theme }
          vim.notify("CodeSnap: Background ENABLED✅", vim.log.levels.INFO)
        else
          -- 隐藏背景：padding设为0
          codesnap.setup { bg_x_padding = 0, bg_y_padding = 0, bg_theme = opts.bg_theme }
          vim.notify("CodeSnap: Background DISABLED🚫", vim.log.levels.INFO)
        end
      end
    end,
  },

  {
    "pogyomo/winresize.nvim",
  },
  {
    "folke/snacks.nvim",

    opts = function(plugin, opts)
      opts.picker.previewers = {
        git = {
          native = true, -- 关键配置项 可以使用delta显示diff
        },
      }
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(plugin, opts)
      local astro, get_icon = require "astrocore", require("astroui").get_icon
      local git_available = vim.fn.executable "git" == 1
      local sources = {
        { source = "filesystem", display_name = get_icon("FolderClosed", 1, true) .. "File" },
        { source = "buffers", display_name = get_icon("DefaultFile", 1, true) .. "Bufs" },
        { source = "diagnostics", display_name = get_icon("Diagnostic", 1, true) .. "Diagnostic" },
      }
      if git_available then
        table.insert(sources, 3, { source = "git_status", display_name = get_icon("Git", 1, true) .. "Git" })
      end
      opts = astro.extend_tbl(opts, {
        enable_git_status = git_available,
        auto_clean_after_session_restore = true,
        close_if_last_window = true,
        -- sources = { "filesystem", "buffers", git_available and "git_status" or nil },
        sources = { "filesystem", git_available and "git_status" or nil },
        -- source_selector = {
        --   winbar = true,
        --   content_layout = "center",
        --   sources = sources,
        -- },
        source_selector = {
          -- content_layout = "center",
          -- sources = sources,
        },
        default_component_configs = {
          -- indent = {
          --   padding = 2,
          --   expander_collapsed = get_icon "FoldClosed",
          --   expander_expanded = get_icon "FoldOpened",
          -- },

          indent = {
            padding = 2,
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            -- expander_collapsed = "",
            -- expander_expanded = "",
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            -- folder_empty_open = get_icon "FolderEmpty",
            default = get_icon "DefaultFile",
            provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
              -- local right_padding = 1
              local right_padding = 0
              if node.type == "file" or node.type == "terminal" then
                local success, web_devicons = pcall(require, "nvim-web-devicons")
                local name = node.type == "terminal" and "terminal" or node.name
                if success then
                  local devicon, hl = web_devicons.get_icon(name)
                  icon.text = devicon or icon.text
                  icon.highlight = hl or icon.highlight
                end
              end
              icon.text = icon.text .. string.rep(" ", right_padding)
            end,
          },
          modified = { symbol = get_icon "FileModified" },
          git_status = {
            symbols = {
              added = get_icon "GitAdd",
              deleted = get_icon "GitDelete",
              modified = get_icon "GitChange",
              renamed = get_icon "GitRenamed",
              untracked = get_icon "GitUntracked",
              ignored = get_icon "GitIgnored",
              unstaged = get_icon "GitUnstaged",
              staged = get_icon "GitStaged",
              conflict = get_icon "GitConflict",
            },
          },
        },
        filesystem = {
          follow_current_file = { enabled = true },
          filtered_items = { hide_gitignored = git_available },
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = vim.fn.has "win32" ~= 1,
        },
      })

      if not opts.event_handlers then opts.event_handlers = {} end
      table.insert(opts.event_handlers, {
        event = "neo_tree_buffer_enter",
        handler = function(_)
          vim.opt_local.signcolumn = "auto"
          vim.opt_local.foldcolumn = "0"
        end,
      })
      return opts
    end,
  },
  {
    "Saghen/blink.cmp",
    opts = function(plugin, opts)
      vim.api.nvim_create_autocmd("CmdlineChanged", {
        callback = function()
          local mode = vim.fn.getcmdtype() -- ":" "/", "?" 等

          -- 仅对 ":" 命令有效
          if mode ~= ":" then return end

          local cmd = vim.fn.getcmdline()

          -- 如果当前cmd以空格结尾（说明你在进入次级命令）
          if cmd:sub(-1) == " " then
            local ok, cmp = pcall(require, "blink.cmp")
            -- if ok then cmp.hide() end
          end
        end,
      })

      local border_type = "solid"
      opts.keymap["<C-J>"] = { "fallback" }
      opts.keymap["<C-K>"] = { "fallback" }
      opts.keymap["<Tab>"] = {
        "snippet_forward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      }
      opts.keymap["<S-Tab>"] = {
        "snippet_backward",
        function(cmp)
          if vim.api.nvim_get_mode().mode == "c" then return cmp.show() end
        end,
        "fallback",
      }
      -- opts.completion.ghost_text = { enabled = true }
      opts.completion.list.selection = { preselect = false, auto_insert = true }
      opts.completion.menu.border = border_type
      opts.completion.menu.scrollbar = false

      opts.completion.menu.draw = {
        -- Aligns the keyword you've typed to a component in the menu
        align_to = "label", -- or 'none' to disable, or 'cursor' to align to the cursor
        -- Left and right padding, optionally { left, right } for different padding on each side
        padding = { 1, 1 },

        -- Gap between columns
        gap = 1,
        -- Priority of the cursorline highlight, setting this to 0 will render it below other highlights
        cursorline_priority = 10000,
        -- Appends an indicator to snippets label
        snippet_indicator = "~",
        -- Use treesitter to highlight the label text for the given list of sources
        -- treesitter = {},
        treesitter = { "lsp" },

        -- Components to render, grouped by column
        -- columns = { { "kind_icon" }, { "label" }, { "kind" } },
        columns = { { "kind_icon" }, { "label" } },

        -- Definitions for possible components to render. Each defines:
        --   ellipsis: whether to add an ellipsis when truncating the text
        --   width: control the min, max and fill behavior of the component
        --   text function: will be called for each item
        --   highlight function: will be called only when the line appears on screen
        components = {
          kind_icon = {
            ellipsis = false,
            text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
            -- Set the highlight priority to 20000 to beat the cursorline's default priority of 10000
            highlight = function(ctx) return { { group = ctx.kind_hl, priority = 20000 } } end,
          },

          kind = {
            ellipsis = false,
            width = { fill = true },
            text = function(ctx) return ctx.kind end,
            highlight = function(ctx) return ctx.kind_hl end,
          },

          label = {
            width = { fill = true, max = 60 },
            text = function(ctx) return ctx.label .. ctx.label_detail end,
            highlight = function(ctx)
              -- label and label details
              local highlights = {
                { 0, #ctx.label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
              }
              if ctx.label_detail then
                table.insert(highlights, { #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" })
              end

              -- characters matched on the label by the fuzzy matcher
              for _, idx in ipairs(ctx.label_matched_indices) do
                table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
              end

              return highlights
            end,
          },

          label_description = {
            width = { max = 30 },
            text = function(ctx) return ctx.label_description end,
            highlight = "BlinkCmpLabelDescription",
          },

          source_name = {
            width = { max = 30 },
            text = function(ctx) return ctx.source_name end,
            highlight = "BlinkCmpSource",
          },

          source_id = {
            width = { max = 30 },
            text = function(ctx) return ctx.source_id end,
            highlight = "BlinkCmpSource",
          },
        },
      }
      opts.signature.window.border = border_type
      opts.completion.documentation.window.border = border_type
      opts.appearance = {

        kind_icons = {
          Namespace = "󰌗 ",
          Text = "󰉿 ",
          Method = "󰆧 ",
          Function = "󰆧 ",
          Constructor = " ",
          Field = "󰜢 ",
          Variable = "󰀫 ",
          Class = "󰠱 ",
          Interface = " ",
          Module = " ",
          Property = "󰜢 ",
          Unit = "󰑭 ",
          Value = "󰎠 ",
          Enum = " ",
          Keyword = "󰌋 ",
          Snippet = " ",
          Color = "󱓻 ",
          File = "󰈚 ",
          Reference = "󰈇 ",
          Folder = "󰉋 ",
          EnumMember = " ",
          Constant = "󰏿 ",
          Struct = "󰙅 ",
          Event = " ",
          Operator = "󰆕 ",
          TypeParameter = "󰊄 ",
          Table = " ",
          Object = "󰅩 ",
          Tag = " ",
          Array = "[]",
          Boolean = " ",
          Number = " ",
          Null = "󰟢 ",
          Supermaven = " ",
          String = "󰉿 ",
          Calendar = " ",
          Watch = "󰥔 ",
          Package = " ",
          Copilot = " ",
          Codeium = " ",
          TabNine = " ",
          BladeNav = " ",
        },
      }
    end,
  },
  {
    "folke/tokyonight.nvim",
    optional = true,
    opts = {
      -- 你可以在这里写 tokyonight 自带的配置，比如 style = "night"
      style = "night",
      on_highlights = function(hl, c)
        -- ========= 白色主体 =========
        hl["@type"] = { fg = "#c0caf5" }
        hl["@module"] = { fg = "#c0caf5" }
        hl["@module.builtin"] = { fg = "#c0caf5" }
        hl["@namespace"] = { fg = "#c0caf5" }
        hl["@variable"] = { fg = "#c0caf5" }
        hl["@property"] = { fg = "#7dcfff" }
        hl["@variable.member"] = { fg = "#7dcfff" }

        -- ========= 点缀色 =========
        hl["@keyword"] = { fg = "#bb9af7", italic = true }
        hl["@function"] = { fg = "#7aa2f7" }
        hl["@punctuation.bracket"] = { fg = "#7aa2f7" }
        hl["@variable.parameter"] = { fg = "#e0af68" }
        hl["@type.builtin"] = { fg = "#bb9af7" }
        hl["@lsp.typemod.type.defaultLibrary"] = { fg = "#bb9af7" }
        hl["@lsp.typemod.type.defaultLibrary.go"] = { fg = "#bb9af7" }
        hl["@string.delimiter"] = { fg = "#89ddff" }
        hl["@punctuation.string"] = { fg = "#89ddff" }

        -- ========= UI/插件类 =========
        hl.MiniIconsAzure = { fg = "#7aa2f7", nocombine = true }

        -- ========= UI 覆写 =========
        hl.FloatBorder = { fg = "#3b4261", bg = "NONE" }
        hl.WinSeparator = { fg = "#3b4261" }
        hl.VertSplit = { fg = "#3b4261" }

        hl.Identifier = { fg = "#7aa2f7" }
        hl.Directory = { fg = "#7aa2f7" }
        hl.Title = { fg = "#7aa2f7", bold = true }

        hl.Special = { fg = "#89ddff" }
        hl.SpecialKey = { fg = "#89ddff" }

        hl.FloatBorder = {
          fg = "#3b4261",
          bg = c.bg_float, -- 跟 NormalFloat 一样
        }

        -- ========= Snacks Indent =========
        hl.SnacksIndent = { fg = "#242532", nocombine = true }
        hl.SnacksIndentScope = { fg = "#3b3f55", nocombine = true }
        hl.SnacksIndentBlank = { fg = "#242532", nocombine = true }
        hl.SnacksIndentChunk = { fg = "#3b3f55", nocombine = true }
      end,
    },
  },

  {
    "folke/edgy.nvim",
    optional = true,
    event = "VeryLazy",
    enabled = false,
    opts = {
      animate = {
        enabled = false,
      },
      left = {
        -- Neo-tree filesystem always takes half the screen height
        {
          title = "Neo-Tree",
          ft = "neo-tree",
          filter = function(buf) return vim.b[buf].neo_tree_source == "filesystem" end,
          size = { height = 0.5 },
        },
      },
      bottom = {
        {
          ft = "trouble",
          title = "Diagnostics",
          size = { height = 0.35 },
          open = "TroubleToggle",
        },
        {
          ft = "qf",
          title = "QuickFix",
          size = { height = 0.25 },
          open = "copen",
        },
        {
          ft = "toggleterm",
          title = "Terminal",
          size = { height = 0.3 },
          filter = function(buf) return not vim.b[buf].lazyterm_cmd end,
          open = function() vim.cmd "ToggleTerm direction=horizontal" end,
        },
      },

      right = {
        {
          ft = "aerial",
          title = "Symbols Outline",
          size = { width = 0.2 },
          open = "AerialToggle",
        },
        {
          ft = "NeogitStatus",
          title = "Neogit",
          size = { width = 0.45 },
          open = function() vim.cmd "Neogit kind=vsplit" end,
        },
        {
          ft = "copilot-chat",
          title = "Copilot Chat",
          size = { width = 0.4 },
          open = function() vim.cmd "CopilotChatToggle" end,
        },
      },

      options = {
        bottom = { wo = { winbar = false }, close_on_last = true },
        right = { wo = { winbar = false }, close_on_last = true },
      },
    },
    config = function(_, opts)
      require("edgy").setup(opts)

      -- -------------------- 独占判定 --------------------
      local bottom_ft = { trouble = true, qf = true, toggleterm = true, spectre_panel = true }
      local right_ft = { aerial = true, NeogitStatus = true, ["copilot-chat"] = true }

      local function is_bottom_win(win)
        if not (win and vim.api.nvim_win_is_valid(win)) then return false end
        local buf = vim.api.nvim_win_get_buf(win)
        local ft, bt = vim.bo[buf].filetype, vim.bo[buf].buftype
        if bt == "terminal" or bt == "quickfix" then return true end
        return bottom_ft[ft] or false
      end

      local function is_right_win(win)
        if not (win and vim.api.nvim_win_is_valid(win)) then return false end
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        return right_ft[ft] or false
      end

      local function close_same_side(win_new)
        if not (win_new and vim.api.nvim_win_is_valid(win_new)) then return end
        local side = is_bottom_win(win_new) and "bottom" or (is_right_win(win_new) and "right" or nil)
        if not side then return end

        local cur_buf = vim.api.nvim_win_get_buf(win_new)

        vim.schedule(function()
          for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if w ~= win_new and vim.api.nvim_win_is_valid(w) then
              local same = (side == "bottom" and is_bottom_win(w)) or (side == "right" and is_right_win(w))
              if same then
                local b = vim.api.nvim_win_get_buf(w)
                -- 🧠 新增：若是同一个 buffer（比如 Trouble 刚创建），就不要关
                if b ~= cur_buf then pcall(vim.api.nvim_win_close, w, true) end
              end
            end
          end
        end)
      end

      local aug = vim.api.nvim_create_augroup("EdgyExclusiveClean", { clear = true })

      -- ① 终端一打开就独占（覆盖 ToggleTerm 等）
      vim.api.nvim_create_autocmd("TermOpen", {
        group = aug,
        callback = function(args)
          local win = vim.fn.bufwinid(args.buf)
          if win ~= -1 then close_same_side(win) end
        end,
      })

      -- ② Quickfix 打开后独占（copen / :make / :grep 等）
      vim.api.nvim_create_autocmd("QuickFixCmdPost", {
        group = aug,
        pattern = { "*" },
        callback = function()
          -- qf 窗口 id
          local ok, info = pcall(vim.fn.getqflist, { winid = 0 })
          if ok and info and info.winid and info.winid > 0 then
            close_same_side(info.winid)
          else
            -- 兜底：遍历寻找 buftype=quickfix 的窗口
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local b = vim.api.nvim_win_get_buf(w)
              if vim.bo[b].buftype == "quickfix" then close_same_side(w) end
            end
          end
        end,
      })

      -- ③ Trouble / Aerial / Neogit / Copilot Chat 等：文件类型或挂载到窗口时独占
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
        group = aug,
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          if bottom_ft[ft] or right_ft[ft] or ft == "qf" then
            local win = vim.fn.bufwinid(args.buf)
            if win ~= -1 then close_same_side(win) end
          end
        end,
      })

      -- ④（可选）Trouble 的用户事件，部分版本支持；有就更顺滑
      vim.api.nvim_create_autocmd("User", {
        group = aug,
        pattern = { "TroubleOpen" },
        callback = function()
          vim.defer_fn(function()
            local win = vim.api.nvim_get_current_win()
            close_same_side(win)
          end, 50)
        end,
      })
    end,
  },

  -- 在 lua/plugins/render-markdown.lua 里写：
  {

    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        width = "block",
        left_pad = 1,
        right_pad = 2,
        sign = false,
        icons = { "󰼏 ", "󰎨 " },
        -- icons = { "󰐣 " },
        -- icons = { "󰉫  ", "󰉬  ", "󰉭  " },
        border = true,
        border_virtual = true,
        backgrounds = {
          "RenderMarkdownH1Bg",
        },
        -- backgrounds = {
        --       'RenderMarkdownH1Bg',
        --       'RenderMarkdownH2Bg',
        --       'RenderMarkdownH3Bg',
        --       'RenderMarkdownH4Bg',
        --       'RenderMarkdownH5Bg',
        --       'RenderMarkdownH6Bg',
        --   },
        --   foregrounds = {
        --       'RenderMarkdownH1',
        --       'RenderMarkdownH2',
        --       'RenderMarkdownH3',
        --       'RenderMarkdownH4',
        --       'RenderMarkdownH5',
        --       'RenderMarkdownH6',
        --   },
      },
      code = {
        width = "block",
        position = "right",
        min_width = 45,
        sign = false,
        left_pad = 2,
        right_pad = 2,
        language_pad = 2,
        border = "thick",
      },
      link = {
        enabled = false, -- TODO: 替换成没那么显眼的样式
      },

      bullet = {
        enabled = true,
        render_modes = false,
        icons = { " ", " ", "◆", "◇" },
        ordered_icons = function(ctx)
          local value = vim.trim(ctx.value)
          local index = tonumber(value:sub(1, #value - 1))
          return ("%d."):format(index > 1 and index or ctx.index)
        end,
        left_pad = 1,
        right_pad = 0,
        -- highlight = "RenderMarkdownBullet",
        highlight = "RenderMarkdownBullet",
        scope_highlight = {},
      },
    },
  },
  {
    "AstroNvim/astrolsp",
    opts = {
      config = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
                extraArgs = { "--profile", "rust-analyzer" },
              },
              check = { command = "clippy" }, -- check（快）或 clippy（严格检查）模式
            },
          },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      -- LazyVim style which-key configuration
      opts.preset = "modern" -- or "classic" or "helix"

      -- Group names (LazyVim style)
      opts.spec = opts.spec or {}

      local spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>a", group = "AI" },
        -- { "<leader>c", group = "code" },
        -- { "<leader>f", group = "file/find" },
        -- { "<leader>g", group = "git" },
        -- { "<leader>gh", group = "hunks" },
        -- { "<leader>q", group = "quit/session" },
        -- { "<leader>s", group = "search" },
        -- { "<leader>u", group = "ui" },
        -- { "<leader>w", group = "windows" },
        -- { "<leader>x", group = "diagnostics/quickfix" },
        -- { "<leader><tab>", group = "tabs" },
        -- { "[", group = "Prev" },
        -- { "]", group = "Next" },
        -- { "g", group = "Goto" },
        -- { "gs", group = "Surround" },
        -- { "z", group = "fold" },
      }

      for _, item in ipairs(spec) do
        table.insert(opts.spec, item)
      end

      -- Visual mode groups
      table.insert(opts.spec, { mode = "v", { "<leader>g", group = "git" } })

      -- Window settings (LazyVim style)
      opts.win = {
        -- border = "rounded",
        border = "single",
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
      }

      -- 右侧小窗口配置
      -- opts.win = {
      --   -- 窗口位置：右侧
      --   position = "right",
      --   -- 窗口大小
      --   width = { min = 20, max = 50 },
      --   height = { min = 4, max = 25 },
      --   -- 边框样式
      --   border = "single",
      --   padding = { 1, 2 },
      --   title = true,
      --   title_pos = "center",
      --   -- 窗口透明度
      --   winblend = 0,
      --   -- z-index
      --   zindex = 1000,
      -- }

      -- Layout settings
      opts.layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },

        spacing = 3,
        align = "left",
      }

      -- Disable some built-in mappings
      opts.disable = {
        buftypes = {},
        filetypes = { "TelescopePrompt" },
      }

      return opts
    end,
  },

  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"

      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.git_branch(),
        status.component.file_info(),
        status.component.git_diff(),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.treesitter(),
        status.component.nav(),
        status.component.mode { surround = { separator = "right" } },
      }

      opts.winbar = { -- winbar
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        fallthrough = false,
        { -- inactive winbar
          condition = function() return not status.condition.is_active() end,
          status.component.separated_path {
            path_func = status.provider.filename { modify = ":.:h" },
          },
          status.component.file_info {
            file_icon = false,
            filename = {},
            filetype = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbarnc", true),
            surround = false,
            update = "BufEnter",
          },
        },
        { -- active winbar
          -- show the path to the file relative to the working directory
          status.component.separated_path {
            path_func = status.provider.filename { modify = ":.:h" },
          },
          -- add the file name and icon
          status.component.file_info { -- add file_info to breadcrumbs
            file_icon = false,
            -- file_icon = { hl = status.hl.filetype_color, padding = { left = 0 } },
            filename = {},
            filetype = false,
            file_modified = false,
            file_read_only = false,
            hl = status.hl.get_attributes("winbar", true),
            surround = false,
            update = "BufEnter",
          },
          -- show the breadcrumbs
          status.component.breadcrumbs {
            icon = { hl = true },
            hl = status.hl.get_attributes("winbar", true),
            prefix = true,
            padding = { left = 0 },
          },
        },
      }

      opts.tabline = { -- tabline
        { -- file tree padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            self.winwidth = vim.api.nvim_win_get_width(self.winid)
            return self.winwidth ~= vim.o.columns -- only apply to sidebars
              and not require("astrocore.buffer").is_valid(vim.api.nvim_win_get_buf(self.winid)) -- if buffer is not in tabline
          end,
          provider = function(self) return (" "):rep(self.winwidth + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist { -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          { -- close button for current tab
            provider = status.provider.close_button {
              kind = "TabClose",
              padding = { left = 1, right = 1 },
            },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astrocore.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      }

      opts.statuscolumn = { -- statuscolumn
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        status.component.foldcolumn(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      }
    end,
  },
  {
    "Yazeed1s/minimal.nvim",
  },
  {
    "rebelot/heirline.nvim",
    -- opts = function(_, opts) opts.winbar = nil end,
  },
  {
    "cryptomilk/nightcity.nvim",
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
  },
}

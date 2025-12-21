-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

-- https://astronvim.github.io/astrocommunity/

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  { import = "astrocommunity.motion.mini-ai" },
  { import = "astrocommunity.motion.mini-surround" },
  { import = "astrocommunity.motion.flash-nvim" },

  { import = "astrocommunity.editing-support.treesj" },

  { import = "astrocommunity.motion.marks-nvim" },
  { import = "astrocommunity.editing-support.dial-nvim" },
  -- { import = "astrocommunity.editing-support.yanky-nvim" },

  -- utils
  { import = "astrocommunity.color.ccc-nvim" },
  { import = "astrocommunity.media.codesnap-nvim" },

  { import = "astrocommunity.split-and-window.edgy-nvim" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  -- { import = "astrocommunity.register.nvim-neoclip-lua" },
  -- { import = "astrocommunity.diagnostics.trouble-nvim" },
  -- { import = "astrocommunity.pack.nvchad-ui" },

  -- UI & theme
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },

  { import = "astrocommunity.ai.opencode-nvim" },
  -- { import = "astrocommunity.editing-support.nvim-treesitter-context" },

  -- { import = "astrocommunity.bars-and-lines.bufferline-nvim" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
  { import = "astrocommunity.recipes.cache-colorscheme" },
  { import = "astrocommunity.test.neotest" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.git.neogit" },
  -- { import = "astrocommunity.utility.hover-nvim" },
  -- { import = "astrocommunity.git.gitgraph-nvim" },

  { import = "astrocommunity.game.leetcode-nvim" },
  -- { import = "astrocommunity.recipes.astrolsp-auto-signature-help" },
  { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" },
  { import = "astrocommunity.recipes.auto-session-restore" },
  -- { import = "astrocommunity.recipes.heirline-vscode-winbar" },
  -- { import = "astrocommunity.media.image-nvim" },
  { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },

  { import = "astrocommunity.pack.full-dadbod" },

  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.zig" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.nix" },

  { import = "astrocommunity.recipes.picker-nvchad-theme" },
  -- { import = "astrocommunity.editing-support.rustowl" },

  -- { import = "astrocommunity.bars-and-lines.dropbar-nvim" },
  -- { import = "astrocommunity.bars-and-lines.lualine-nvim" },

  -- { import = "astrocommunity.code-runner.molten-nvim" },
  -- { import = "astrocommunity.code-runner.conjure" },
  -- { import = "astrocommunity.code-runner.sniprun" },
  -- { import = "astrocommunity.git.git-blame-nvim" },
  -- { import = "astrocommunity.git.blame-nvim" },
  -- { import = "astrocommunity.git.fugit2-nvim" },
  -- import/override with your plugins folder
  --
}

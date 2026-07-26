{
  inputs,
  pkgs,
  lib,
  config,
  system,
  ...
}:

let
  cfg = config.features.interactive-cli;
in
{
  options.features.interactive-cli.enable = lib.mkEnableOption "Interactive command-line tools";

  config = lib.mkIf cfg.enable {
    programs = {
      bat = {
        enable = true;
        config = {
          color = "auto";
          pager = "less";
          paging = "never";
          map-syntax = [
            ".ignore:.gitignore"
          ];
        };
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
        defaultOptions = [
          "--ansi"

          "--multi"

          "--bind 'ctrl-/:toggle-preview'"
          "--bind 'ctrl-u:preview-half-page-up'"
          "--bind 'ctrl-d:preview-half-page-down'"

          "--preview-window=right:50%:hidden"
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | rg -q \"image/\"; then timg -g \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"

          "--layout=reverse"
          "--height 60%"

          # "--header='^/ toggle preview  ^D ^U scroll preview  TAB select multi'"

          "--color=fg:#d0d0d0,fg+:#d0d0d0,bg:-1,bg+:#262626"
          "--color=hl:#6546ff,hl+:#ff9adf,info:#676767,marker:#6546ff"
          "--color=prompt:#676767,spinner:#6546ff,pointer:#6546ff,header:#434343"
          "--color=border:#262626,label:#676767,query:#d9d9d9,scrollbar:#676767"
          "--separator='─' --scrollbar='▌' --layout='reverse' --info='right'"
          "--preview-window='border-sharp' --prompt='' --marker='▎ ' --pointer='' "
        ];
        fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
        fileWidgetOptions = [
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | rg -q \"image/\"; then timg -g \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"
        ];
        historyWidgetOptions = [
          "--sort"
          "--exact"
          "--preview 'echo {}'"
          "--preview-window=down:3:hidden"
          "--bind 'ctrl-/:toggle-preview'"
        ];
      };

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv = {
          enable = true;
        };
        config.global = {
          # Make direnv messages less verbose
          hide_env_diff = true;
        };
      };

      ripgrep.enable = true;

      jq.enable = true;

      fastfetch.enable = true;

      btop.enable = true;

      yazi = {
        enable = true;
        enableZshIntegration = true;
        keymap = {
          mgr.prepend_keymap = [
            {
              on = [ "<C-/>" "<C-->" ];
              run = "plugin toggle-pane min-preview";
              desc = "Show or hide the preview pane";
            }
            {
              on = [ "<C-/>" "<C-->" ];
              run = "plugin toggle-pane max-preview";
              desc = "Maximize or restore the preview pane";
            }
            {
              on = [ "<C-d>" ];
              run = "seek 5";
              desc = "Preview page down";
            }
            {
              on = [ "<C-u>" ];
              run = "seek -5";
              desc = "Preview page up";
            }
          ];
        };
        settings = {
          mgr = {
            show_hidden = false;
            sort_by = "mtime";
            sort_dir_first = true;
            sort_reverse = true;
            ratio = [ 1 3 6 ];
          };
          preview = {
            max_width = 2000;
            max_height = 1200;
          };
          plugin = {
            prepend_previewers = [
              { name = "*.csv"; run = "duckdb"; }
              { name = "*.tsv"; run = "duckdb"; }
              # { name = "*.json"; run = "duckdb"; }
              { name = "*.parquet"; run = "duckdb"; }
              # { name = "*.txt"; run = "duckdb"; }
              { name = "*.xlsx"; run = "duckdb"; }
              { name = "*.db"; run = "duckdb"; }
              { name = "*.duckdb"; run = "duckdb"; }
            ];

            prepend_preloaders = [
              { name = "*.csv"; run = "duckdb"; multi = false; }
              { name = "*.tsv"; run = "duckdb"; multi = false; }
              # { name = "*.json"; run = "duckdb"; multi = false; }
              { name = "*.parquet"; run = "duckdb"; multi = false; }
              # { name = "*.txt"; run = "duckdb"; multi = false; }
              { name = "*.xlsx"; run = "duckdb"; multi = false; }
            ];
          };
        };
      };

      eza = {
        enable = true;
        icons = "auto";
        colors = "auto";
        git = true;
        enableZshIntegration = true;
        extraOptions = [
          # "--time-style long-iso"
        ];
      };

      fd = {
        enable = true;
        ignores = [
          ".git/"
          "node_modules/"
          "venv/"
          "site-packages/"
          ".DS_Store"
        ];
      };

    };
    home.packages = with pkgs; [
      # Runtime dependencies for fzf/Yazi previews.
      timg
      duf
      duckdb
    ];

    # home.sessionVariables = {
    #   FZF_COMPLETION_TRIGGER = "?";
    # };

    # catppuccin = {
    #   bat.enable = true;
    #   fzf.enable = true;
    # };
  };
}

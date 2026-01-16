{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = config.modules.shell;
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  options.modules.shell = {
    enable = lib.mkEnableOption "Shell base tools";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      bat = {
        enable = true;
        config = {
          color = "auto";
          pager = "delta";
          paging = "never";
          map-syntax = [
            ".ignore:.gitignore"
          ];
        };
      };

      opencode = {
        enable = true;
        package = pkgs-unstable.opencode;
      };

      

      fzf = {
        enable = true;
        enableZshIntegration = true;
        defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
        defaultOptions = [
          "--layout=reverse"
          "--height 45%"
          "--bind 'ctrl-/:toggle-preview'"
          "--bind 'ctrl-u:preview-half-page-up'"
          "--bind 'ctrl-d:preview-half-page-down'"
          "--scrollbar='▌ '"
          "--multi"
          "--header='^/ toggle-preview  ^D ^U scroll-preview  TAB select-multi'"
          "--preview-window=right:50%:hidden"
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | grep -q \"image/\"; then chafa -f iterm -s \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"
        ];
        fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
        fileWidgetOptions = [
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | grep -q \"image/\"; then chafa -f iterm -s \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"
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
        settings = {
          mgr = {
            show_hidden = false;
            sort_by = "mtime";
            sort_dir_first = true;
            sort_reverse = true;
            ratio = [
              1
              3
              6
            ];
          };
          preview = {
            max_width = 2000;
            max_height = 1200;
          };
        };
      };

      eza = {
        enable = true;
        icons = "auto";
        colors = "auto";
        git = true;
        enableZshIntegration = true;
        extraOptions = [ ];
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
      age
      act
      coreutils
      curl
      csvkit
      # viu
      timg
      duf
      delta
      dust
      duckdb
      entr
      file
      findutils
      fontconfig
      # gdu
      pngpaste
      gnugrep
      gnumake
      gnused
      gnutar
      gum
      grex
      libqalculate
      lsof
      moor
      mosh
      procs
      rsync
      sops
      sttr
      tldr
      trash-cli
      tree
      unrar
      unzip
      wget
      just
      sshpass
      tokei
      # inputs.nix-fast-build.packages.${pkgs.system}.default
      mycli
      mysql-shell
      xh
      yq
      # zstd # 用不上
    ];

    home.sessionVariables = {
      FZF_COMPLETION_TRIGGER = "?";
    };
    # catppuccin = {
    #   bat.enable = true;
    #   fzf.enable = true;
    # };
  };
}

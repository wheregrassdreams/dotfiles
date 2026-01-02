{ pkgs, lib, config, ... }:

let
  cfg = config.modules.shell;
in {
  options.modules.shell = {
    enable = lib.mkEnableOption "Shell base tools";
  };

  config = lib.mkIf cfg.enable {
    programs = {

      bat = {
        enable = true;
        config = {
          color = "auto";
          italic-text = "never";
          style = "numbers";
          pager = "delta";
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
        fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
        fileWidgetOptions = [
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | grep -q \"image/\"; then chafa -f iterm -s \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"
        ];
        historyWidgetOptions = [
          "--sort"
          "--exact"
        ];
      };

      ripgrep.enable = true;

      jq.enable = true;

      fastfetch.enable = true;

      btop.enable = true;
    };
    home.packages = with pkgs; [
      age
      coreutils
      curl
      eza
      duf
      delta
      dust
      entr
      file
      fd
      findutils
      fontconfig
      gdu
      gnugrep
      gnumake
      gnused
      gnutar
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
      xh
      yq
      yazi
      zstd
    ];
    # catppuccin = {
    #   bat.enable = true;
    #   fzf.enable = true;
    # };
  };
}

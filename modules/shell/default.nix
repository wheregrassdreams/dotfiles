{ pkgs, lib, config, ... }:

let
  cfg = config.modules.shell;
in {
  options.modules.shell.enable = lib.mkEnableOption "Shell configuration";

  config = lib.mkIf cfg.enable {
    programs = {
      zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = ["--cmd cd"];
      };
      bat = {
        enable = true;
        config = {
          color = "always";
          italic-text = "always";
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
      pay-respects = {
        enable = true;
        enableZshIntegration = true;
        options = [
          "--alias"
          "f"
        ];
      };
      ripgrep.enable = true;
      jq.enable = true;
      fastfetch.enable = true;
    };
    home.packages = with pkgs; [
      trash-cli
      libqalculate
      moor
      dust
      duf
      procs
    ];
    catppuccin = {
      bat.enable = true;
      fzf.enable = true;
    };
  };
}

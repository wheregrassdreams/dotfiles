{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    tmuxp.enable = true;
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    escapeTime = 10;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-dir "${config.xdg.dataHome}/tmux/resurrect"
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      tmuxPlugins.dotbar
      tmuxPlugins.vim-tmux-navigator
    ];
    extraConfig = ''
      bind ',' run-shell 'tmux source-file ${config.xdg.configHome}/tmux/tmux.conf \; display-message -d 800 "config reloaded"'
      set -g allow-passthrough on
      set -g renumber-windows on
      set -g set-clipboard on
      set -g focus-events on
    '';
  };
}

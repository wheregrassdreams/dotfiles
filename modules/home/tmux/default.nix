{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux/tmux.conf;
  };

  home.file = {
    ".config/tmux/plugins".source = ./tmux/plugins;
    ".config/tmux/scripts".source = ./tmux/scripts;
  };
}

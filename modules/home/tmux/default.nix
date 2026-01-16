{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux/tmux.conf;
    plugins =
      with pkgs.tmuxPlugins; [
        resurrect
        continuum
        dotbar
      ];
  };

  home.file = {
    # ".config/tmux/plugins".source = ./tmux/plugins;
    ".config/tmux/scripts".source = ./tmux/scripts;
  };
}

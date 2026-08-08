{
  identity,
  lib,
  pkgs,
  ...
}:
let
  xdgOpen = pkgs.writeShellApplication {
    name = "xdg-open";
    runtimeInputs = [ pkgs.wslu ];
    text = ''
      exec wslview "$@"
    '';
  };
in
{
  imports = [
    ../../../modules/home
    ../../../modules/home/data/home.nix
    ../../../modules/home/services
    ../../profiles/workstation/home.nix
  ];

  my = {
    identity = identity;
    paths.personal.windows = "/mnt/c";
  };

  # WSLg provides Wayland, while zsh-system-clipboard otherwise prefers the
  # X11 path whenever DISPLAY is present. Windows handles URL and file opening.
  home = {
    packages = [
      pkgs.wl-clipboard
      pkgs.wslu
      xdgOpen
    ];
    sessionVariables = {
      BROWSER = "wslview";
      ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD = "1";
    };
  };

  # home.sessionVariables is skipped when an inherited shell has already
  # sourced a previous Home Manager generation. Zsh loads this before plugins.
  programs.zsh.envExtra = lib.mkAfter ''
    export ZSH_SYSTEM_CLIPBOARD_USE_WL_CLIPBOARD=1
  '';
}

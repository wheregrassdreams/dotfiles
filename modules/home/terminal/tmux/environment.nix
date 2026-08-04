{ config, lib, pkgs, ... }:
let
  tmux = "${pkgs.tmux}/bin/tmux";
  configFile = "${config.xdg.configHome}/tmux/tmux.conf";
  sessionVariables = [
    "PATH"
    "NIX_PROFILES"
    "NIX_PATH"
    "XDG_CONFIG_HOME"
    "XDG_DATA_HOME"
    "XDG_CACHE_HOME"
    "XDG_STATE_HOME"
    "SSH_AUTH_SOCK"
    "DISPLAY"
    "TERM"
    "TERM_PROGRAM"
  ];
  updateEnvironment = lib.concatStringsSep " " sessionVariables;
  setGlobalEnvironment = lib.concatMapStringsSep "\n" (name: ''
    ${tmux} set-environment -g ${name} "''${${name}-}"
  '') sessionVariables;
in
{
  programs.tmux.extraConfig = lib.mkAfter ''
    set -g update-environment "${updateEnvironment}"
  '';

  home.activation.reloadTmux = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ${tmux} has-session 2>/dev/null; then
      ${setGlobalEnvironment}
      ${tmux} source-file ${lib.escapeShellArg configFile}
    fi
  '';
}

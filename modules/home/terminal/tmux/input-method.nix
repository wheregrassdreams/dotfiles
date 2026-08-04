{ config, lib, feature, ... }:
let
  inputMethod = feature.inputMethod.command;
in
{
  programs.tmux.extraConfig = lib.mkAfter (lib.optionalString (inputMethod != null) ''
    set -g @tmux-input-method-command '${inputMethod}'
    set -g @tmux-input-method-layout 'com.apple.keylayout.ABC'
  '');
}

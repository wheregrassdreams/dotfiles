{ config, lib, isDarwin, ... }:

let
  cfg = config.modules.ghostty;

  commonSettings = {
    theme = "Hardcore";
    font-family = "JetBrains Mono";
    font-style = "Medium";
    font-size = 14;
    adjust-cell-height = "15%";
    adjust-font-baseline = "-10%";
    background-opacity = 0.90;
    background-blur-radius = 64;
    quick-terminal-animation-duration = 0;
    title = " ";
    window-padding-x = "16,16";
    window-padding-y = 0;
    clipboard-read = "allow";
    clipboard-write = "allow";
    window-colorspace = "srgb";
    cursor-opacity = 1;
    custom-shader = "./my-shaders/virtual_cursor.glsl";
    confirm-close-surface = false;
    keybind = [
      "ctrl+shift+v=ignore"
      "ctrl+shift+s=ignore"
      "ctrl+shift+t=ignore"
      "global:super+grave_accent=toggle_quick_terminal"
      "alt+shift+p=ignore"
      "shift+enter=text:\\x1b\\r"
    ];
  };

  darwinSettings = {
    macos-titlebar-proxy-icon = "hidden";
    macos-option-as-alt = "left";
    macos-icon = "glass";
  };

  ghosttySettings = commonSettings // lib.optionalAttrs isDarwin darwinSettings;
in {
  options.modules.ghostty.enable = lib.mkEnableOption "Ghostty configuration";

  config = lib.mkIf cfg.enable {
    programs.ghostty = lib.mkIf (!isDarwin) {
      enable = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      installVimSyntax = true;
      settings = ghosttySettings;
    };
    xdg.configFile."ghostty".source = ./config;
  };
}

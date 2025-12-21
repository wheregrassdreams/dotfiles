{ config, lib, pkgs-unstable, isDarwin, ... }:

let
  cfg = config.modules.freecad;
in {
  options.modules.freecad.enable = lib.mkEnableOption "FreeCAD Configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs-unstable; lib.optionals (!isDarwin) [
      freecad-wayland
    ];

    home.file = lib.mkMerge [
      (lib.mkIf isDarwin {
        "Library/Preferences/FreeCAD".source = ./config;
        "Library/Application Support/FreeCAD/Macro".source = ./share/Macro;
      })
      (lib.mkIf (!isDarwin) {
        ".config/FreeCAD".source = ./config;
        ".local/share/FreeCAD/Macro".source = ./share/Macro;
      })
    ];
  };
}

{ lib, ... }:
{
  options.my.system.darwin.dock = {
    enable = lib.mkEnableOption "Dock";
    entries = lib.mkOption {
      type = with lib.types; listOf (submodule {
        options = {
          path = lib.mkOption { type = str; };
          section = lib.mkOption { type = str; default = "apps"; };
          options = lib.mkOption { type = str; default = ""; };
        };
      });
      default = [ ];
    };
    username = lib.mkOption { type = lib.types.str; };
  };
}

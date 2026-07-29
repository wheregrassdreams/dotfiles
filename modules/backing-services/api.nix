{ lib, ... }:
let
  modeType = lib.types.nullOr (lib.types.enum [
    "docker-only"
    "local-manual"
    "local-daemon"
  ]);
  component = name: {
    enable = lib.mkEnableOption name;
    mode = lib.mkOption {
      type = modeType;
      default = null;
      description = "runtime mode for ${name}; null inherits backingServices.defaultMode";
    };
    client.enable = lib.mkEnableOption "${name} client tools" // { default = true; };
  };
in {
  options.dotfiles.backingServices = {
    enable = lib.mkEnableOption "backing services";
    defaultMode = lib.mkOption {
      type = lib.types.enum [ "docker-only" "local-manual" "local-daemon" ];
      default = "local-daemon";
      description = "default runtime mode for enabled backing services";
    };
    mysql = component "MySQL";
    postgres = component "PostgreSQL";
    redis = component "Redis";
  };
}

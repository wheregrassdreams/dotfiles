{ lib, ... }:
let
  modeType = lib.types.nullOr (lib.types.enum [
    "external"
    "local-manual"
    "local-daemon"
  ]);
  component = name: {
    enable = lib.mkEnableOption name;
    mode = lib.mkOption {
      type = modeType;
      default = null;
      description = "runtime mode for ${name}; null inherits services.defaultMode";
    };
    client.enable = lib.mkEnableOption "${name} client tools" // { default = true; };
  };
in {
  options.my.services = {
    defaultMode = lib.mkOption {
      type = lib.types.enum [ "external" "local-manual" "local-daemon" ];
      default = "external";
      description = "default lifecycle mode for enabled local services";
    };
    mysql = component "MySQL";
    postgres = component "PostgreSQL";
    redis = component "Redis";
  };
}

{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.services;
  modeOf = component: if component.mode != null then component.mode else cfg.defaultMode;
  isManual = component: component.enable && modeOf component == "local-manual";
  isDaemon = component: component.enable && modeOf component == "local-daemon";
in {
  imports = [ ../options/services.nix ];

  config = {
    assertions = map (name: {
      assertion = let component = cfg.${name}; in component.enable || component.mode == null;
      message = "dotfiles.services.${name}.mode requires dotfiles.services.${name}.enable";
    }) [ "mysql" "postgres" "redis" ];

    environment.systemPackages =
      lib.optionals (isManual cfg.mysql) [ pkgs.mysql84 ]
      ++ lib.optionals (isManual cfg.postgres) [ pkgs.postgresql ]
      ++ lib.optionals (isManual cfg.redis) [ pkgs.redis ];

    services.mysql = lib.mkIf (isDaemon cfg.mysql) {
      enable = true;
      package = pkgs.mysql84;
    };
    services.postgresql.enable = isDaemon cfg.postgres;
    services.redis.servers."".enable = isDaemon cfg.redis;
  };
}

{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.backingServices;
  modeOf = component:
    if cfg.enable && component.enable
    then if component.mode != null then component.mode else cfg.defaultMode
    else "docker-only";
  isManual = component: modeOf component == "local-manual";
  isDaemon = component: modeOf component == "local-daemon";
in {
  config = {
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

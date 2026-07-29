{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.services;
  enabledClient = component: component.enable && component.client.enable;
in {
  imports = [ ../options/services.nix ];

  config.home.packages =
    lib.optionals (enabledClient cfg.mysql) [ pkgs.mycli pkgs.mysql-shell ]
    ++ lib.optionals (enabledClient cfg.postgres) [ pkgs.pgcli pkgs.postgresql ]
    ++ lib.optionals (enabledClient cfg.redis) [ pkgs.iredis ];
}

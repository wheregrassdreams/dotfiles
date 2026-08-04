{ config, lib, pkgs, ... }:
let
  cfg = config.my.services;
  components = [
    { name = "mysql"; formula = "mysql"; settings = cfg.mysql; }
    { name = "postgres"; formula = "postgresql@17"; settings = cfg.postgres; }
    { name = "redis"; formula = "redis"; settings = cfg.redis; }
  ];
  modeOf = component:
    if component.settings.mode != null then component.settings.mode else cfg.defaultMode;
  enabledComponents = builtins.filter (component: component.settings.enable) components;
  localComponents = builtins.filter (component: modeOf component != "external") enabledComponents;
  daemonComponents = builtins.filter (component: modeOf component == "local-daemon") enabledComponents;
  stoppedComponents = builtins.filter (component: modeOf component != "local-daemon") enabledComponents;
  enabledClient = component: component.enable && component.client.enable;
in {
  imports = [
    ../../options/services.nix
    ../../options/homebrew.nix
  ];

  config = {
    assertions = map (component: {
      assertion = component.settings.enable || component.settings.mode == null;
      message = "my.services.${component.name}.mode requires my.services.${component.name}.enable";
    }) components;

    my.homebrew.brews = map (component: component.formula) localComponents;

    home.packages =
      lib.optionals (enabledClient cfg.mysql) [ pkgs.mycli pkgs.mysql-shell ]
      ++ lib.optionals (enabledClient cfg.postgres) [ pkgs.pgcli pkgs.postgresql ]
      ++ lib.optionals (enabledClient cfg.redis) [ pkgs.iredis ];

    home.activation.manageHomebrewServices = lib.mkIf (stoppedComponents != [ ] || daemonComponents != [ ]) (
      lib.hm.dag.entryAfter [ "brewBundle" ] ''
      brew=${lib.escapeShellArg "${config.my.homebrew.brewPrefix}/bin/brew"}
      if [ -x "$brew" ]; then
        ${lib.concatMapStrings (component: ''
          "$brew" services stop ${lib.escapeShellArg component.formula} >/dev/null 2>&1 || true
        '') stoppedComponents}
        ${lib.concatMapStrings (component: ''
          "$brew" services start ${lib.escapeShellArg component.formula}
        '') daemonComponents}
      fi
      ''
    );
  };
}

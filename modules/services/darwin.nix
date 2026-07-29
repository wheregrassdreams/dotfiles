{ config, lib, userName, ... }:
let
  cfg = config.dotfiles.services;
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
  stop = component: ''
    sudo --user=${lib.escapeShellArg userName} --set-home "$brew" services stop ${lib.escapeShellArg component.formula} >/dev/null 2>&1 || true
  '';
  start = component: ''
    sudo --user=${lib.escapeShellArg userName} --set-home "$brew" services start ${lib.escapeShellArg component.formula}
  '';
in {
  imports = [ ../options/services.nix ];

  config = {
    assertions = map (component: {
      assertion = component.settings.enable || component.settings.mode == null;
      message = "dotfiles.services.${component.name}.mode requires dotfiles.services.${component.name}.enable";
    }) components;

    homebrew.brews = map (component: component.formula) localComponents;

    system.activationScripts.services = {
      text = ''
        brew=${lib.escapeShellArg "${config.homebrew.brewPrefix}/brew"}
        if [ -x "$brew" ]; then
          ${lib.concatMapStrings stop stoppedComponents}
          ${lib.concatMapStrings start daemonComponents}
        fi
      '';
    };
  };
}

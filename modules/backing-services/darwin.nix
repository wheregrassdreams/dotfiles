{ config, lib, userName, ... }:
let
  cfg = config.dotfiles.backingServices;
  components = [
    { name = "mysql"; formula = "mysql"; settings = cfg.mysql; }
    { name = "postgres"; formula = "postgresql@17"; settings = cfg.postgres; }
    { name = "redis"; formula = "redis"; settings = cfg.redis; }
  ];
  modeOf = component:
    if cfg.enable && component.settings.enable
    then if component.settings.mode != null then component.settings.mode else cfg.defaultMode
    else "docker-only";
  localComponents = builtins.filter (component: modeOf component != "docker-only") components;
  daemonComponents = builtins.filter (component: modeOf component == "local-daemon") components;
  stoppedComponents = builtins.filter (component: modeOf component != "local-daemon") components;
  stop = component: ''
    sudo --user=${lib.escapeShellArg userName} --set-home "$brew" services stop ${lib.escapeShellArg component.formula} >/dev/null 2>&1 || true
  '';
  start = component: ''
    sudo --user=${lib.escapeShellArg userName} --set-home "$brew" services start ${lib.escapeShellArg component.formula}
  '';
in {
  config = {
    homebrew.brews = map (component: component.formula) localComponents;

    system.activationScripts.backingServices = {
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

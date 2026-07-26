{ config, lib, ... }:
let cfg = config.features.dev-go;
in {
  options.features.dev-go.enable = lib.mkEnableOption "Go development tools";
  config = lib.mkIf cfg.enable {
    programs.go = {
      enable = true;
      packages = {};
      env = {
        GOPATH = "${config.home.homeDirectory}/.go";
        # GOBIN = "${config.home.homeDirectory}/.go/bin";
        GOBIN = "${config.home.homeDirectory}/.local/bin";
        GOMODCACHE = "${config.home.homeDirectory}/.go/pkg/mod";
        GOCACHE = "${config.xdg.cacheHome}/go-build";
        GOENV = "${config.xdg.dataHome}/go/env";
      };
    };
    home.sessionPath = [ "$HOME/.go/bin" ];
  };
}

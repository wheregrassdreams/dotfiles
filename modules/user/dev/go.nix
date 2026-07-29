{ config, ... }:
let
  goPath = "${config.xdg.dataHome}/go";
  localBin = "${config.home.homeDirectory}/.local/bin";
in {
  programs.go = {
    enable = true;
    packages = { };
    env = {
      GOPATH     = goPath;
      GOBIN      = localBin;
      GOENV      = "${goPath}/env";
      GOMODCACHE = "${goPath}/pkg/mod";
      GOCACHE    = "${config.xdg.cacheHome}/go-build";
    };
  };
  # home.sessionPath = [ programs.go.env.GOBIN ];
}

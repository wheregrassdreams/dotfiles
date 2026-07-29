{ config, ... }:
let
  paths = config.dotfiles.paths;
  goPath = "${paths.xdg.data}/go";
in {
  programs.go = {
    enable = true;
    packages = { };
    env = {
      GOPATH     = goPath;
      GOBIN      = paths.localBin;
      GOENV      = "${goPath}/env";
      GOMODCACHE = "${goPath}/pkg/mod";
      GOCACHE    = "${paths.xdg.cache}/go-build";
    };
  };
  # home.sessionPath = [ programs.go.env.GOBIN ];
}

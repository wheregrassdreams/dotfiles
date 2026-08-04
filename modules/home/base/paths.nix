{ config, lib, dotfilesPath, ... }:
let
  cfg = config.my.paths;
  locationVariable = name:
    "DOTFILES_PATH_${lib.toUpper (lib.replaceStrings [ "-" "." "/" " " ] [ "_" "_" "_" "_" ] name)}";
  locationVariables = lib.mapAttrs' (name: path: {
    name = locationVariable name;
    value = path;
  }) cfg.personal;
in {
  config = {
    my.paths = {
      home = lib.mkDefault config.home.homeDirectory;
      dotfiles = lib.mkDefault dotfilesPath;
      localBin = lib.mkDefault "${config.home.homeDirectory}/.local/bin";
      xdg = {
        config = lib.mkDefault config.xdg.configHome;
        data = lib.mkDefault config.xdg.dataHome;
        cache = lib.mkDefault config.xdg.cacheHome;
        state = lib.mkDefault config.xdg.stateHome;
      };
    };

    home.sessionVariables = {
      DOTFILES = cfg.dotfiles;
      DOTFILES_HOME = cfg.home;
      DOTFILES_LOCAL_BIN_DIR = cfg.localBin;
      DOTFILES_XDG_CONFIG_DIR = cfg.xdg.config;
      DOTFILES_XDG_DATA_DIR = cfg.xdg.data;
      DOTFILES_XDG_CACHE_DIR = cfg.xdg.cache;
      DOTFILES_XDG_STATE_DIR = cfg.xdg.state;
    } // locationVariables;

    home.sessionPath = [ cfg.localBin ];
  };
}

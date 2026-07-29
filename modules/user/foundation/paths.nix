{ config, lib, dotfilesPath, ... }:
let
  cfg = config.dotfiles.paths;
  locationVariable = name:
    "DOTFILES_PATH_${lib.toUpper (lib.replaceStrings [ "-" "." "/" " " ] [ "_" "_" "_" "_" ] name)}";
  locationVariables = lib.mapAttrs' (name: path: {
    name = locationVariable name;
    value = path;
  }) cfg.personal;
  locationVariableNames = map locationVariable (builtins.attrNames cfg.personal);
in {
  options.dotfiles.paths = {
    home = lib.mkOption {
      default = config.home.homeDirectory;
      readOnly = true;
    };
    dotfiles = lib.mkOption {
      default = dotfilesPath;
      readOnly = true;
    };
    localBin = lib.mkOption {
      default = "${config.home.homeDirectory}/.local/bin";
      readOnly = true;
    };
    xdg = {
      config = lib.mkOption { default = config.xdg.configHome; readOnly = true; };
      data   = lib.mkOption { default = config.xdg.dataHome;   readOnly = true; };
      cache  = lib.mkOption { default = config.xdg.cacheHome;  readOnly = true; };
      state  = lib.mkOption { default = config.xdg.stateHome;  readOnly = true; };
    };
    locations = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Named personal and business locations";
      default = { };
    };

    # homebrew 位置
  };

  config = {
    assertions = [{
      assertion = builtins.length locationVariableNames == builtins.length (lib.unique locationVariableNames);
      message = "dotfiles.paths.personal contains names that map to the same DOTFILES_PATH_* environment variable";
    }];

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

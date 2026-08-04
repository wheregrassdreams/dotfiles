{ lib, ... }:
{
  options.dotfiles.homebrew = {
    enable = lib.mkEnableOption "Homebrew package synchronization";

    brewPrefix = lib.mkOption {
      type = lib.types.str;
      default = "/opt/homebrew";
      description = "Homebrew installation prefix for this host";
    };

    taps = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; };
          trusted = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "trust this non-official Homebrew tap during bundle synchronization";
          };
        };
      });
      default = [ ];
      description = "Homebrew taps to declare in the generated Brewfile";
    };

    brews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Homebrew formulae to install";
    };

    casks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Homebrew casks to install";
    };

    masApps = lib.mkOption {
      type = lib.types.attrsOf lib.types.int;
      default = { };
      description = "Mac App Store applications to declare in the generated Brewfile";
    };

    sync = {
      enable = lib.mkEnableOption "Homebrew synchronization during Home Manager activation" // { default = true; };
      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "allow brew to update its package metadata during synchronization";
      };
      upgrade = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "upgrade already installed declared packages during synchronization";
      };
      cleanup = lib.mkOption {
        type = lib.types.enum [ "none" "uninstall" "zap" ];
        default = "none";
        description = "how synchronization handles packages absent from the declared Brewfile";
      };
      strict = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "fail Home Manager activation when Homebrew synchronization fails";
      };
    };
  };
}

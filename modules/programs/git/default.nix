{ config, lib, pkgs, ... }:

let
  cfg = config.modules.git;
in {
  options.modules.git.enable = lib.mkEnableOption "git configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      delta
      gh
      git-filter-repo
      git-lfs
    ];
    home.file.".gitconfig".source = ./config/.gitconfig.global;
  };
}

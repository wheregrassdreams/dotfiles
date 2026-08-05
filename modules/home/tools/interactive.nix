{ pkgs, lib, ... }@args:
lib.mkMerge [
  (import ./fzf/base.nix args)
  (import ./yazi/base.nix args)
  {
    programs = {
      bat = {
        enable = true;
        config = {
          color = "auto";
          pager = "less";
          paging = "never";
          map-syntax = [ ".ignore:.gitignore" ];
        };
      };
      fastfetch.enable = true;
      btop.enable = true;
      eza = {
        enable = true;
        icons = "auto";
        colors = "auto";
        git = true;
        enableZshIntegration = true;
      };
    };

    home.packages = with pkgs; [
      timg
      duf
      dust
      moor
      procs

    ];
  }
]

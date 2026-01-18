{ userName, pkgs, ... }:
{
  home-manager.users.${userName} = { ... }: {
    home.packages = [ pkgs.goku ];
    xdg.configFile."karabiner.edn" = {
      source = ./karabiner.edn;
      onChange = "${pkgs.goku}/bin/goku";
    };
  };
}

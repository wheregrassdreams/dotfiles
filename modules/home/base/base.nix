{ config, lib, userName, ... }:
# let homeDir = config.home.homeDirectory;
# in
{
  home.username = userName;

  # xdg = {
  #   enable = true;
  #   configHome = "${homeDir}/.config";
  #   dataHome =   "${homeDir}/.local/share";
  #   cacheHome =  "${homeDir}/.cache";
  #   stateHome =  "${homeDir}/.local/state";
  # };

  home.sessionVariables = {
    LANG   = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}

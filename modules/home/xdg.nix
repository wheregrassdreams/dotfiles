{ ... }:
{
  xdg = {
    enable = true;
    configHome = "$HOME/.config";
    cacheHome = "$HOME/.cache";
    dataHome = "$HOME/.local/share";
  };

  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
  };
}

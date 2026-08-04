{ ... }:
{
  my.homebrew = {
    enable = true;
    sync = {
      enable = true;
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
      strict = true;
    };
  };
}

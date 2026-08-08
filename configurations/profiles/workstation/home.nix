{ ... }:
{
  imports = [ ../minimal-terminal/home.nix ];

  my = {
    tools = {
      workflow = true;
      interactive = true;
      television = true;
    };

    development = {
      enable = true;
      nix = true;
      python = {
        enable = true;
        suite = "minimal";
      };
      javascript = false;
      go = false;
      rust = false;
      clang = {
        enable = true;
        opengl.enable = false;
      };
    };
  };
}

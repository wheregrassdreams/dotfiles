{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my;
in
{
  config = lib.mkIf (cfg.git.enable && cfg.git.github.enable) {
    home.packages = [ pkgs.gh ];
    programs.ssh.matchBlocks."github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      identityFile = "~/.ssh/id_ed25519_github_wsl";
      identitiesOnly = true;
    };
  };
}

{
  config,
  lib,
  ...
}:
let
  cfg = config.my;
in
{
  config = lib.mkIf (cfg.git.enable && cfg.git.github.enable) {
    programs.gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    programs.ssh.matchBlocks."github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
      identitiesOnly = true;
    };
  };
}

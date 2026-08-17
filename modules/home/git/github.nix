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
    # programs.gh = {
    #   enable = true;
    #   settings.git_protocol = "ssh";
    # };
    # gh会修改自己的配置（比如使用oauth登录的时候），
    # 而上面的配置会导致与本地gh配置冲突，
    # 因此只声明包
    home.packages = [ pkgs.gh ];
    programs.ssh.matchBlocks."github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
      identitiesOnly = true;
    };
  };
}

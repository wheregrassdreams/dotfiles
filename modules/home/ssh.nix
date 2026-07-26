{ config, lib, ... }:
let cfg = config.features.ssh;
in {
  options.features.ssh.enable = lib.mkEnableOption "SSH access configuration";
  config = lib.mkIf cfg.enable {
  home.file.".ssh/config".text = ''
    Host github.com
    Hostname ssh.github.com
    Port 443
    User git

    Host *
    SetEnv TERM=xterm-256color
    ServerAliveInterval 30
    ServerAliveCountMax 3
  '';
  };
}

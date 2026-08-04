{ config, lib, userName, hostName, dotfilesPath, pkgs, ... }:
{
  nix.enable = false; # 使用determinate

  networking = {
    applicationFirewall.enable = true;
    computerName = hostName;
    localHostName = hostName;
  };

  users.users.${userName} = {
    home = "/Users/${userName}";
  };

  # Security
  # 支持使用更多认证方式
  environment.systemPackages = [ pkgs.pam-reattach ];
  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true; # Touch ID
    watchIdAuth = true; # Watch ID
  };

}

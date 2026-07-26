{ lib, userName, hostName, inputs, pkgs, ... }:

{

  nix.enable = false; # 使用determinate

  environment.variables = {
    DOTFILES = "/Users/${userName}/.dotfiles";
    # BROWSER = "zen";
  };

  home-manager.backupFileExtension = "bak";

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

  system.stateVersion = 5;

  # local.dock = {
  #   enable = true;
  #   username = userName;
  #   entries = [
  #     { path = "/Applications/TickTick.app/"; }
  #
  #   ];
  # };
}

{ lib, userName, hostName, inputs, pkgs, ... }:

{

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./karabiner
    # ./dock
  ];

  nix.enable = false; # 使用determinate

  # Homebrew
  nix-homebrew = {
    enable = true;
    user = userName;
    enableRosetta = false;
    mutableTaps = true;
    taps = {};
  };
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  environment.variables = {
    DOTFILES = "/Users/${userName}/.dotfiles";
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

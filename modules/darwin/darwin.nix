{ lib, userName, hostName, inputs, pkgs, ... }:

{

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    # ./dock
  ];

  nix.enable = false;

  # Homebrew
  nix-homebrew = {
    enable = true;
    user = userName;
    enableRosetta = false;
    # 强制管理 brew 安装（推荐）
    mutableTaps = true;
    taps = {
      "homebrew/core" = inputs.homebrew-core;
      "homebrew/cask" = inputs.homebrew-cask;
      # "homebrew/bundle" = inputs.homebrew-bundle;
    };
  };
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

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
  environment.systemPackages = [ pkgs.pam-reattach ];
  security.pam.services.sudo_local = {
    enable = true;
    reattach = true;
    touchIdAuth = true;
    watchIdAuth = true;
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

{ hostName, userName, ... }:
{
  imports = [
    ../../../modules/system/nix.nix
    ../../../modules/system/nixos.nix
    ../../../modules/system/services/nixos.nix
    ../../profiles/minimal-terminal/system.nix
  ];

  config = {
    wsl = {
      enable = true;
      defaultUser = userName;
    };
    system.stateVersion = "25.11";
    networking.hostName = hostName;
    time.timeZone = "Asia/Shanghai";
  };
}

{
  hostName,
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/system/nix.nix
    ../../../modules/system/base-tools.nix
    ../../../modules/system/nixos.nix
    ../../../modules/system/services/nixos.nix
  ];

  config = {
    system.stateVersion = "25.11";
    networking.hostName = hostName;
    time.timeZone = "Asia/Shanghai";

    users.users.zane = {
      isNormalUser = true;
      uid = 1001;
      home = "/home/zane";
      createHome = true;
      description = "Zane Lu";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };
  };
}

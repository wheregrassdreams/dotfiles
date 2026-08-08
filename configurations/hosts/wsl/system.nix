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
    programs.ssh.startAgent = true;

    users.users.zane = {
      isNormalUser = true;
      # Keep this numeric identity stable. DrvFS metadata records UIDs rather
      # than usernames, so a future rename must retain UID 1000.
      uid = 1000;
      home = "/home/zane";
      createHome = true;
      description = "Zane Lu";
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
    };

  };
}

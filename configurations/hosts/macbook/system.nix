{ hostName, userName, ... }:
{
  imports = [
    ../../../modules/system/nix.nix
    ../../../modules/system/darwin/determinate.nix
    ../../../modules/system/darwin
  ];

  config = {
    system.stateVersion = 5;
    system.primaryUser = userName;
    networking.hostName = hostName;
    time.timeZone = "Asia/Shanghai";

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = false;
      remapCapsLockToEscape = false;
      nonUS.remapTilde = true;
    };

    system.startup.chime = false;
  };
}

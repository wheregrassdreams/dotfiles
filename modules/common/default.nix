{ config, lib, pkgs, system, userName, hostName, isDarwin ? false, inputs ? {}, ... }:

{
  nix = lib.mkIf (!isDarwin) {
    settings = {
      builders-use-substitutes = true;
      extra-experimental-features = [ "flakes" "nix-command" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs = {
    hostPlatform = system;
    overlays = [];
  };

  networking.hostName = hostName;
  time.timeZone = "Asia/Shanghai";

}

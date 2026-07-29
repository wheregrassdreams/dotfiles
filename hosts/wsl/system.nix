{ ... }: { imports = [
  ../../modules/platform/nix.nix
  ../../modules/platform/nixos.nix
  ../../modules/backing-services/default.nix
  ../../modules/backing-services/nixos.nix
  ../../profiles/minimal-terminal/system.nix
]; }

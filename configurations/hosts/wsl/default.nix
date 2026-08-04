rec {
  system = "x86_64-linux";
  identity = import ../../profiles/me.nix;
  userName = identity.username;
  hostName = "wsl";
  isWsl = true;
  hostModule = ./system.nix;
  systemModules = [ ];
  homeModules = [ ./home.nix ];
}

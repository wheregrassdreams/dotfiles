rec {
  system = "aarch64-darwin";
  identity = import ../../profiles/me.nix;
  userName = identity.username;
  hostName = "macbook";
  isDarwin = true;
  hostModule = ./system.nix;
  systemModules = [ ];
  homeModules = [ ./home.nix ];
}

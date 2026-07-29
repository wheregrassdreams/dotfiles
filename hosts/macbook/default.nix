rec {
  system = "aarch64-darwin";
  identity = import ../../profiles/identity/zanelu.nix;
  userName = identity.username;
  hostName = "macbook";
  isDarwin = true;
  hostModule = ./host.nix;
  systemModules = [ ./system.nix ];
  homeModules = [ ./home.nix ];
}

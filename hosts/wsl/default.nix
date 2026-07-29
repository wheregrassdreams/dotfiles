rec {
  system = "x86_64-linux";
  identity = import ../../profiles/identity/zanelu.nix;
  userName = identity.username;
  hostName = "wsl";
  isWsl = true;
  hostModule = ./host.nix;
  systemModules = [ ./system.nix ];
  homeModules = [ ./home.nix ];
}

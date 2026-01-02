{ nixpkgs, overlays ? [], inputs, self ? null }:

name:
{
  system,
  user,
  hostName,
  stateVersion ? null,
  isDarwin ? false,
  isWSL ? false
}:

let
  # hostDir = ../hosts/${name};

  hostConfig = ../hosts/${name}/default.nix;
  userOSConfig = ../users/${user}/${if isDarwin then "darwin" else "nixos"}.nix;
  userHomeConfig = ../users/${user}/home.nix;

  systemFunc =
    if isDarwin then inputs.nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  homeManagerModule =
    if isDarwin then inputs.home-manager.darwinModules.home-manager
    else inputs.home-manager.nixosModules.home-manager;
in
systemFunc {
  inherit system;

  specialArgs = {
    inherit
      inputs
      self
      system
      hostName
      stateVersion
      isDarwin
      isWSL;
    userName = user;
    isWsl = isWSL;
  };

  modules =
    [
      { nixpkgs.overlays = overlays; }
      { nixpkgs.config.allowUnfree = true; }

      hostConfig
      userOSConfig
      homeManagerModule
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = { config, ... }: {
          imports = [ userHomeConfig ];
          home.homeDirectory =
            if isDarwin then "/Users/${user}" else "/home/${user}";
        };
        home-manager.sharedModules = [ ../modules/home ];
        home-manager.extraSpecialArgs = {
          inherit inputs system hostName;
          flake = self;
          userName = user;
          isDarwin = isDarwin;
          isWsl = isWSL;
        };
      }
    ]
    ++ nixpkgs.lib.optionals isWSL [
      inputs.nixos-wsl.nixosModules.wsl
    ];
}

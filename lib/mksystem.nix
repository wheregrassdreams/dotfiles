{ nixpkgs, overlays ? [], inputs, self ? null }:

name:
{
  system,
  user,
  hostName,
  stateVersion ? null,
  isDarwin ? false,
  isWSL ? false,
  systemProfiles ? [],
  homeProfiles ? []
}:

let
  # hostDir = ../hosts/${name};

  hostConfig = ../hosts/${name}/default.nix;
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

      (if isDarwin then inputs.sops-nix.darwinModules.sops else inputs.sops-nix.nixosModules.sops)
      hostConfig
      ../platforms/${if isDarwin then "darwin" else "nixos"}
      homeManagerModule
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = { config, ... }: {
          imports = [ userHomeConfig ] ++ homeProfiles;
          home.homeDirectory =
            if isDarwin then "/Users/${user}" else "/home/${user}";
        };
        home-manager.sharedModules = [
          ../modules/home
          inputs.sops-nix.homeManagerModules.sops
        ];
        home-manager.extraSpecialArgs = {
          inherit inputs system hostName;
          flake = self;
          userName = user;
          isDarwin = isDarwin;
          isWsl = isWSL;
        };
      }
    ]
    ++ systemProfiles
    ++ nixpkgs.lib.optionals isWSL [
      inputs.nixos-wsl.nixosModules.wsl
    ];
}

{ nixpkgs, overlays ? [], inputs }:

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
    hostDir = ../hosts/${name};
    machineConfig = hostDir + "/system.nix";
    hostHome = hostDir + "/home.nix";
    userOSConfig = ../users/${user}/${if isDarwin then "darwin" else "nixos" }.nix;

    systemFunc = if isDarwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
    commonArgs = {
      inherit system;
      specialArgs = {
        inherit system hostName stateVersion isDarwin isWSL inputs;
        userName = user;
      };
    };
    commonModules = [
      ../modules/common.nix
      (if isDarwin then ../modules/darwin.nix else ../modules/nixos.nix)
      ../modules/home.nix
    ];
in systemFunc (commonArgs // rec {
    inherit system;

    modules = [
        { nixpkgs.overlays = overlays; }
        { nixpkgs.config.allowUnfree = true; }
        (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})
    ] ++ [
        machineConfig
        userOSConfig
        {
            config._module.args = {
                currentSystem = system;
                currentSystemName = name;
                currentSystemUser = user;
                hostName = hostName;
                stateVersion = stateVersion;
                isDarwin = isDarwin;
                isWSL = isWSL;
                inputs = inputs;
                hostHome = hostHome;
            };
        }
    ] ++ commonModules;
}))

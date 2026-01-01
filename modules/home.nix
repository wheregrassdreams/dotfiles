{ config, lib, pkgs, ... }:
let
  args = config._module.args;
  user = args.currentSystemUser;
  hostHome = args.hostHome;
  userHMConfig = ../users/${user}/home-manager.nix;
  userHMModule = import userHMConfig {
    inherit (args) isDarwin isWSL inputs;
  };
in {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = userHMModule // {
      imports = (userHMModule.imports or []) ++ lib.mkIf (hostHome != null) [ hostHome ];
    };
    extraSpecialArgs = pkgs.lib.mkForce args;
  };
}

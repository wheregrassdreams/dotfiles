{ inputs, ... }: {
  imports = [
    ../../modules/common
    ../../modules/darwin/darwin.nix
    ../../modules/darwin/nix.nix
    ../../modules/darwin/settings.nix
    inputs.determinate.darwinModules.default
  ];
}

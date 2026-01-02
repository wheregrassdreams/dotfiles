{ inputs, ... }: {
  imports = [
    ../../modules/common
    inputs.determinate.darwinModules.default
    ../../modules/darwin/darwin.nix
    ../../modules/darwin/nix.nix
    ../../modules/darwin/settings.nix
  ];
}

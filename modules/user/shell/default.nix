{ dotfilesLib, config, lib, pkgs, inputs, dotfilesPath, hostName, userName, ... }@ctx:
let
  inherit (dotfilesLib.feature) group;
in
dotfilesLib.domain ctx {
  namespace = "my.shell";
  description = "shell environment";

  features = {
    zsh = {
      description = "portable Zsh shell";
      module = ./zsh/base.nix;
      settings = { };
    };
    prompt = {
      description = "shell prompt";
      module = ./prompt.nix;
      settings = { };
    };
    integrations = group {
      macos = {
        description = "macOS shell conveniences";
        module = ./macos.nix;
        settings = { };
      };
      nixConfiguration = {
        description = "Nix configuration workflow commands";
        module = ./nix-configuration.nix;
        settings = { };
      };
      nixIndex = {
        description = "Nix command discovery";
        module = ./nix-index.nix;
        settings = { };
      };
    };
  };
}

{ dotfilesLib, config, lib, pkgs, inputs, dotfilesPath, hostName, userName, ... }@ctx:
dotfilesLib.domain ctx {
  namespace = "dotfiles.shell";
  description = "shell environment";
  base = ./environment.nix;

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
  };

  groups.integrations.features = {
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
}

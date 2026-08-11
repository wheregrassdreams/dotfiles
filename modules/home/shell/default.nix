{
  dotfilesLib,
  config,
  lib,
  pkgs,
  inputs,
  dotfilesPath,
  hostName,
  userName,
  ...
}@ctx:
let
  inherit (dotfilesLib.feature) group;
  domainArgs = ctx // {
    inherit
      config
      pkgs
      inputs
      dotfilesPath
      hostName
      userName
      ;
  };
in
dotfilesLib.domain domainArgs {
  namespace = "my.shell";
  description = "shell environment";

  features = {
    zsh = {
      description = "portable Zsh shell";
      module = ./zsh/base.nix;
      settings = {
        clipboard = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "system clipboard integration" // {
              default = true;
            };
          };
          default = { };
          description = "Whether to load zsh-system-clipboard when a supported backend is available.";
        };
      };
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
      nixIndex = {
        description = "Nix command discovery";
        module = ./nix-index.nix;
        settings = { };
      };
    };
  };
}

{
  dotfilesLib,
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}@ctx:
let
  domainArgs = ctx // {
    inherit
      config
      lib
      pkgs
      inputs
      system
      ;
  };
in
dotfilesLib.domain domainArgs {
  namespace = "my.tools";
  description = "command-line tools";

  features = {
    core = {
      description = "core CLI tools";
      module = ./core.nix;
    };
    direnv = {
      description = "project environment loading with direnv";
      module = ./direnv.nix;
    };
    query = {
      description = "search and structured data tools";
      module = ./query.nix;
    };
    network = {
      description = "network and remote access tools";
      module = ./network.nix;
    };
    workflow = {
      description = "command-line workflow tools";
      module = ./workflow.nix;
    };
    interactive = {
      description = "interactive tools, including FZF and Yazi";
      module = ./interactive.nix;
    };
    television = {
      description = "Television interactive search";
      module = ./television.nix;
    };
    media = {
      description = "media CLI tools";
      module = ./media.nix;
    };
  };
}

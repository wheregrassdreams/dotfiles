{ dotfilesLib, config, lib, pkgs, inputs, system, ... }@ctx:
dotfilesLib.domain ctx {
  namespace = "my.cli";
  description = "command-line tools";

  features = {
    core = { description = "core CLI tools"; module = ./core.nix; };
    query = { description = "search and structured data tools"; module = ./query.nix; };
    network = { description = "network and remote access tools"; module = ./network.nix; };
    workflow = { description = "command-line workflow tools"; module = ./workflow.nix; };
    interactive = { description = "interactive tools, including FZF and Yazi"; module = ./interactive.nix; };
    media = { description = "media CLI tools"; module = ./media.nix; };
  };
}

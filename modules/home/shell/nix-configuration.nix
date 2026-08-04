{ config, hostName, userName, ... }:
{
  home.shellAliases = {
    rebuild = "sudo ${if config.home.homeDirectory == "/Users/${userName}" then "darwin-rebuild" else "nixos-rebuild"} switch --flake $DOTFILES#${hostName}";
    hm = "nix run --inputs-from $DOTFILES home-manager -- switch --flake $DOTFILES#${userName}-${hostName}";
    hm-build = "nix run --inputs-from $DOTFILES home-manager -- build --flake $DOTFILES#${userName}-${hostName}";
    update-nix = "nix flake update nixpkgs nixpkgs-unstable nix-darwin home-manager --flake $DOTFILES";
    clean = "nix-collect-garbage -d && sudo nix-collect-garbage -d && nix store optimise";
  };
}

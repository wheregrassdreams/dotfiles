{ ... }:
{
  home.shellAliases = {
    o = "open";
    reveal = "open -R ";
    update-homebrew = "nix flake update nix-homebrew homebrew-core homebrew-cask --flake $DOTFILES";
  };
}

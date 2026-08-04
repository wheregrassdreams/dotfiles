{ ... }:
{
  home.shellAliases = {
    o = "open";
    reveal = "open -R ";
    update-nix-homebrew = "nix flake update nix-homebrew --flake $DOTFILES";
  };
}

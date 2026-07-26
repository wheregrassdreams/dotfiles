{ nixpkgs, inputs, self ? null }:
{
  system,
  userName,
  hostName,
  isDarwin ? false,
  isWsl ? false,
  homeProfiles ? []
}:
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ inputs.nur.overlays.default inputs.llm-agents.overlays.default ];
  };
  extraSpecialArgs = { inherit inputs self system userName hostName isDarwin isWsl; flake = self; };
  modules = [
    inputs.sops-nix.homeManagerModules.sops
    ../modules/home
    ../users/${userName}/home.nix
    { home.homeDirectory = if isDarwin then "/Users/${userName}" else "/home/${userName}"; }
  ] ++ homeProfiles;
}

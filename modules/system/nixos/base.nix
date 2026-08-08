{ pkgs, ... }:
{
  programs.zsh.enable = true;

  # Rescue and bootstrap tools. The daily CLI environment is provided by
  # Home Manager profiles instead of the system closure.
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    bubblewrap
  ];
}

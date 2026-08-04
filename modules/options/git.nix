{ lib, ... }:
{
  options.my.git = {
    enable = lib.mkEnableOption "Git tooling";
    gitea.enable = lib.mkEnableOption "Gitea CLI";
    github.enable = lib.mkEnableOption "GitHub CLI";
    gitlab.enable = lib.mkEnableOption "GitLab CLI";
    interactive.enable = lib.mkEnableOption "interactive Git tooling";
  };
}

{ ... }:
{
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  my = {
    shell = {
      enable = true;
      zsh.enable = true;
      prompt.enable = true;
      integrations.nixConfiguration.enable = true;
    };
    terminal = {
      enable = true;
      tmux.enable = true;
    };
    tools = {
      enable = true;
      core = true;
      direnv = true;
      query = true;
      network = true;
    };
    git = {
      enable = true;
      interactive.enable = true;
      github.enable = true;
    };
    ssh.enable = true;
  };
}

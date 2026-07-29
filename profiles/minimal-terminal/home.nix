{ ... }: {
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;
  dotfiles = {
    shell = {
      enable = true;
      zsh.enable = true;
      prompt.enable = true;
      integrations.nixConfiguration.enable = true;
    };
    terminal.tmux.enable = true;
    cli = { core = true; query = true; network = true; };
    git = {
      enable = true;
      interactive.enable = true;
      github.enable = true;
    };
    ssh.enable = true;
  };
}

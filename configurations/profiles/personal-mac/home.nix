{ ... }: {
  my = {
    ssh.enable = true;
    secrets.enable = true;
    shell = {
      enable = true;
      zsh.enable = true;
      prompt.enable = true;

      integrations = {
        macos.enable = true;
        nixConfiguration.enable = true;
        nixIndex.enable = true;
      };
    };

    terminal = {
      enable = true;
      tmux.enable = true;
    };

    tools = {
      core = true;
      query = true;
      network = true;
      workflow = true;
      interactive = true;
      media = true;
    };

    git = {
      enable = true;
      # lazygit
      interactive.enable = true;
      # client
      github.enable = true;
      gitlab.enable = false;
      gitea.enable = true;
    };

    development = {
      enable = true;
      # languages
      lua        = true;
      nix        = true;
      go         = true;
      javascript = true;
      rust       = true;
      haskell    = false; # 工具链占用空间过大，暂时不在mac上用
      python     = {
        enable = true;
        suite = "full";
      };
      clang      = {
        enable = true;
        opengl.enable = true;
      };
    };
  };
}

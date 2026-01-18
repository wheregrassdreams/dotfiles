{ isDarwin, isWsl, config, ... }: {
  home.stateVersion = "25.11";
  modules = {
    shell.enable = true;
    dev.enable = true;
    nvim.enable = true;
    secrets.enable = true;
  };
  me = {
    username = "zanelu";
    fullname = "Zane Lu";
    email = "lv2497712968@outlook.com";
  };
  programs.git.includes = [
    {
      condition = "gitdir:~/Work/";
      path = "~/Work/.gitconfig";
    }
  ];

  home.enableNixpkgsReleaseCheck = false;
  assertions = [
  ];
}

{ userName, ... }: {
  wsl = {
    enable = true;
    defaultUser = userName;
  };
  system.stateVersion = "25.11";
}

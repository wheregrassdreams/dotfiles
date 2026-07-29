{ userName, hostName, ... }: {
  wsl = {
    enable = true;
    defaultUser = userName;
  };
  system.stateVersion = "25.11";
  networking.hostName = hostName;
  time.timeZone = "Asia/Shanghai";
}

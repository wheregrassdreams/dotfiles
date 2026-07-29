{ userName, hostName, ... }: {
  system.stateVersion = 5;
  system.primaryUser = userName;
  networking.hostName = hostName;
  time.timeZone = "Asia/Shanghai";
}

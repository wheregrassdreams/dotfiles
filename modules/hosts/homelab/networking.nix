{ ... }: {
  networking = {
    hostName = "homelab";
    networkmanager.enable = true;
    dhcpcd.enable = false;
  };
}

{ config, ... }: {
  # FIXME: hostname应该使用homelab的host， my.connectivity.tailscale.host是本机的host
  #
  # programs.ssh.matchBlocks = {
  #   homelab = { hostname = config.my.connectivity.tailscale.host; user = "zane"; };
  #   "workbench.homelab dev.homelab" = {
  #     hostname = config.my.connectivity.tailscale.host;
  #     user = "dev";
  #     port = 2223;
  #     forwardAgent = true;
  #   };
  # };
}

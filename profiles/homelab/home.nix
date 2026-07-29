{ config, ... }: {
  # FIXME: hostname应该使用homelab的host， dotfiles.connectivity.tailscale.host是本机的host
  #
  # programs.ssh.matchBlocks = {
  #   homelab = { hostname = config.dotfiles.connectivity.tailscale.host; user = "zane"; };
  #   "workbench.homelab dev.homelab" = {
  #     hostname = config.dotfiles.connectivity.tailscale.host;
  #     user = "dev";
  #     port = 2223;
  #     forwardAgent = true;
  #   };
  # };
}

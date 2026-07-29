{ config, ... }: {
  programs.ssh.matchBlocks = {
    homelab = { hostname = config.dotfiles.desktop.network.tailscale.host; user = "zane"; };
    "workbench.homelab dev.homelab" = {
      hostname = config.dotfiles.desktop.network.tailscale.host;
      user = "dev";
      port = 2223;
      forwardAgent = true;
    };
  };
}

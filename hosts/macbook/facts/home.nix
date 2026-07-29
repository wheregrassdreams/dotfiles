{ config, ... }: {
  dotfiles.connectivity.tailscale.host = "homelab.tail50e8c0.ts.net";
  dotfiles.paths.personal = {
    work = "${config.home.homeDirectory}/Work";
    notes = "${config.home.homeDirectory}/Workspace/notes";
  };
}

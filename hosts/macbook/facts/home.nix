{ config, ... }: {
  my.homebrew.brewPrefix = "/opt/homebrew";
  my.connectivity.tailscale.host = "homelab.tail50e8c0.ts.net";
  my.paths.personal = {
    work = "${config.home.homeDirectory}/Work";
    notes = "${config.home.homeDirectory}/Workspace/notes";
  };
}

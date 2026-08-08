{
  config,
  hostName,
  userName,
  ...
}:
let
  defaultUser = config.users.users.${userName};
in
{
  assertions = [
    {
      assertion = builtins.hasAttr config.wsl.defaultUser config.users.users;
      message = "wsl.defaultUser must name a declared NixOS user.";
    }
  ];

  wsl = {
    enable = true;
    defaultUser = userName;
    interop.register = true;
    useWindowsDriver = false;

    # Keep the existing /etc/wsl.conf behavior declarative. WSLg's graphics
    # and X11/Wayland integration remain provided by NixOS-WSL itself.
    wslConf = {
      automount = {
        enabled = true;
        ldconfig = false;
        mountFsTab = false;
        # DrvFS stores Linux ownership as metadata. Derive the mount UID from
        # the declared default user so changing that user cannot leave newly
        # created Windows-side state owned by a stale UID.
        options = "metadata,uid=${toString defaultUser.uid},gid=100";
        root = "/mnt";
      };
      boot.systemd = true;
      interop = {
        enabled = true;
        appendWindowsPath = true;
      };
      network = {
        generateHosts = true;
        generateResolvConf = true;
        hostname = hostName;
      };
      user.default = userName;
    };
  };
}

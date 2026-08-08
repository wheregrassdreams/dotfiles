{ hostName, userName, ... }:
{
  wsl = {
    enable = true;
    defaultUser = userName;
    useWindowsDriver = false;

    # Keep the existing /etc/wsl.conf behavior declarative. WSLg's graphics
    # and X11/Wayland integration remain provided by NixOS-WSL itself.
    wslConf = {
      automount = {
        enabled = true;
        ldconfig = false;
        mountFsTab = false;
        options = "metadata,uid=1000,gid=100";
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

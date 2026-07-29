{ config, lib, ... }: {
  system.defaults.CustomUserPreferences."com.apple.frameworks.diskimages" = {
    skip-verify = true;
    skip-verify-locked = true;
    skip-verify-remote = true;
    auto-mount-removable = false;
    auto-mount-notifications = false;
  };
}

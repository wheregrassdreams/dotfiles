{
  determinate-nix.customSettings = {
    experimental-features = "nix-command flakes";
    trusted-users = "root @admin";
    sandbox = true;
    auto-optimise-store = true;
  };
}

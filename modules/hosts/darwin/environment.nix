{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.pam-reattach
  ];
}

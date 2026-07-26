{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.secrets;
in
{
  options.features.secrets.enable = lib.mkEnableOption "Secrets via sops-nix";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sops
      age
      ssh-to-age
    ];

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = "${config.xdg.configHome}/sops/age/keys.txt";
      SOPS_AGE_SSH_PRIVATE_KEY_FILE = "${config.home.homeDirectory}/.ssh/id_ed25519";
    };

    sops = {
      age = {
        keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        sshKeyPaths = [
          "${config.home.homeDirectory}/.ssh/id_ed25519"
        ];
      };
    };
  };
}

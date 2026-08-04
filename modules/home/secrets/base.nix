{ config, pkgs, lib, ... }:
let
  sopsAgeKeyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  sshPrivateKeyFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
in {
  options.my.secrets.enable = lib.mkEnableOption "SOPS tooling";

  config = lib.mkIf config.my.secrets.enable {
    home.packages = with pkgs; [ sops age ssh-to-age ];

    sops.age = {
      keyFile = sopsAgeKeyFile;
      sshKeyPaths = [ sshPrivateKeyFile ];
    };

    home.sessionVariables = {
      SOPS_AGE_KEY_FILE = sopsAgeKeyFile;
      SOPS_AGE_SSH_PRIVATE_KEY_FILE = sshPrivateKeyFile;
    };
  };
}

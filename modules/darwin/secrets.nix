{ config, pkgs, agenix, userName, secrets, ... }:

{
  age = {
    identityPaths = [
      "/Users/${userName}/.ssh/id_ed25519"
    ];

    secrets = {
      "syncthing-cert" = {
        symlink = true;
        path = "/Users/${userName}/Library/Application Support/Syncthing/cert.pem";
        file =  "${secrets}/darwin-syncthing-cert.age";
        mode = "644";
        owner = "${userName}";
        group = "staff";
      };

      "syncthing-key" = {
        symlink = true;
        path = "/Users/${userName}/Library/Application Support/Syncthing/key.pem";
        file =  "${secrets}/darwin-syncthing-key.age";
        mode = "600";
        owner = "${userName}";
        group = "staff";
      };

      "github-ssh-key" = {
        symlink = true;
        path = "/Users/${userName}/.ssh/id_github";
        file =  "${secrets}/github-ssh-key.age";
        mode = "600";
        owner = "${userName}";
        group = "staff";
      };

      "github-signing-key" = {
        symlink = false;
        path = "/Users/${userName}/.ssh/pgp_github.key";
        file =  "${secrets}/github-signing-key.age";
        mode = "600";
        owner = "${userName}";
      };
    };
  };
}

{ config, lib, ... }:
let
  enable = name: lib.mkEnableOption name;
in {
  options.bundles = {
    minimal-terminal.enable = enable "minimal terminal";
    terminal.enable = enable "terminal experience";
    interactive-cli.enable = enable "interactive CLI";
    version-control.enable = enable "version control";
    developer.enable = enable "development environment";
    secure-access.enable = enable "secure access";
    personal-mac.enable = enable "personal macOS environment";
  };

  config = lib.mkMerge [
    (lib.mkIf config.bundles.minimal-terminal.enable {
      features = { base-cli.enable = true; ssh.enable = true; git.enable = true; terminal.enable = true; };
    })
    (lib.mkIf config.bundles.terminal.enable { features.terminal.enable = true; })
    (lib.mkIf config.bundles.interactive-cli.enable { features.interactive-cli.enable = true; })
    (lib.mkIf config.bundles.version-control.enable { features.git.enable = true; })
    (lib.mkIf config.bundles.secure-access.enable { features = { ssh.enable = true; secrets.enable = true; }; })
    (lib.mkIf config.bundles.developer.enable {
      features = { dev-common.enable = true; dev-nix.enable = true; dev-go.enable = true; dev-javascript.enable = true; dev-rust.enable = true; dev-python-data.enable = true; };
    })
    (lib.mkIf config.bundles.personal-mac.enable {
      bundles = { terminal.enable = true; interactive-cli.enable = true; version-control.enable = true; developer.enable = true; secure-access.enable = true; };
      features = { base-cli.enable = true; data-cli.enable = true; media-cli.enable = true; ai-cli.enable = true; work.enable = true; ghostty.enable = true; nix-index.enable = true; };
    })
  ];
}

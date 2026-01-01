{
  description = "Zane's dotfiles";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11?shallow=1";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable?shallow=1";
    home-manager = {
      url = "github:nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs-otbr.url = "github:mrene/nixpkgs/openthread-border-router?shallow=1";
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nur = {
    #   url = "github:nix-community/NUR?shallow=1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    sops-nix = {
      url = "github:Mic92/sops-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi?shallow=1";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew?shallow=1";
    # lanzaboote = {
    #   url = "github:nix-community/lanzaboote?shallow=1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    homebrew-core = {
      url = "github:homebrew/homebrew-core?shallow=1";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask?shallow=1";
      flake = false;
    };
    apple-emoji-linux = {
      url = "github:samuelngs/apple-emoji-linux?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # catppuccin = {
    #   url = "github:catppuccin/nix?shallow=1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # catppuccin-themes = {
    #   url = "github:abhinandh-s/catppuccin-nix?shallow=1";
    # };
    hyprland.url = "github:hyprwm/Hyprland?shallow=1";
    dgop = {
      url = "github:AvengeMedia/dgop?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # dankMaterialShell = {
    #   url = "github:AvengeMedia/DankMaterialShell?shallow=1";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    #   inputs.dgop.follows = "dgop";
    # };
    # wezterm = {
    #   url = "github:wez/wezterm?dir=nix&shallow=1";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
    fenix = {
      url = "github:nix-community/fenix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    affinity = {
      url = "github:mrshmllow/affinity-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      mkSystem = import ./lib/mksystem.nix {
        inherit nixpkgs;
        overlays = [];
        inputs = inputs;
      };

      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      nixosConfigurations = {
        Desktop = mkSystem "desktop" {
          system = "x86_64-linux";
          user = "zanelu";
          hostName = "Desktop";
          stateVersion = "25.05";
        };

        Homelab = mkSystem "homelab" {
          system = "x86_64-linux";
          user = "zanelu";
          hostName = "Homelab";
          stateVersion = "25.05";
        };

        WSL = mkSystem "wsl" {
          system = "x86_64-linux";
          user = "zanelu";
          hostName = "WSL";
          stateVersion = "25.05";
          isWSL = true;
        };


      };

      darwinConfigurations = let
        hostName = let
          hostCmd = nixpkgs.legacyPackages.${"aarch64-darwin"}.runCommand "hostname" { } ''
            /usr/sbin/scutil --get LocalHostName | tr -d '\n' > $out
          '';
        in builtins.readFile hostCmd;
      in {
        ${hostName} = mkSystem "darwin" {
          system = "aarch64-darwin";
          user = "zanelu";
          hostName = hostName;
          stateVersion = "25.05";
          isDarwin = true;
        };
      };

      packages = forAllSystems (system: {
        bootstrapIsoX86 = (nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./modules/hosts/bootstrap.nix ];
        }).config.system.build.isoImage;
        bootstrapIsoArm = (nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ ./modules/hosts/bootstrap.nix ];
        }).config.system.build.isoImage;
      });
    };
}

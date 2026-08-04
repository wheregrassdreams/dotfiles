{
  description = "Zane's dotfiles";

  # 这里定义整个系统/用户配置所依赖的外部 flake。
  inputs = {
    # Stable nixpkgs：作为系统和 home-manager 的主 pkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11?shallow=1";

    # Unstable nixpkgs：用于个别需要新版本的软件
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable?shallow=1";

    # Home Manager：用户态配置，必须与主 nixpkgs 保持一致
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin：macOS 系统配置
    nix-darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS on WSL 支持
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew：在 nix-darwin 上管理 Homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew?shallow=1";
    # Apple 字体 / emoji（Linux 上使用）
    apple-emoji-linux = {
      url = "github:samuelngs/apple-emoji-linux?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Rust toolchain 管理（比 nixpkgs 自带的更新）
    fenix = {
      url = "github:nix-community/fenix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Affinity 软件（依赖 unstable）
    affinity = {
      url = "github:mrshmllow/affinity-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # LLM agents / AI tooling（作为工具使用）
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # sops-nix：用于管理 secrets（系统模块型工具）
    sops-nix = {
      url = "github:Mic92/sops-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

     # Build tools
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs = {
        # flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
        # treefmt-nix.follows = "treefmt-nix";
      };
    };

    # Development tools
    # git-hooks = {
    #   url = "github:cachix/git-hooks.nix";
    #   inputs = {
    #     flake-compat.follows = "flake-compat";
    #     nixpkgs.follows = "nixpkgs";
    #   };
    # };
    # treefmt-nix = {
    #   url = "github:numtide/treefmt-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # # Utility inputs
    # flake-compat = {
    #   url = "github:edolstra/flake-compat";
    #   flake = false;
    # };
    #
    # flake-parts.url = "github:hercules-ci/flake-parts";
    # nixos-unified.url = "github:srid/nixos-unified";
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        darwin.follows = "nix-darwin";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3.8.6";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 这是 flake 的入口（main）：
  outputs = inputs@{ self, nixpkgs, ... }:
    let
      overlays = [
        inputs.nur.overlays.default
        inputs.llm-agents.overlays.default
      ];
      dotfilesLib = import ./lib {
        lib = nixpkgs.lib;
        inherit nixpkgs inputs self overlays;
      };
      flakeLib = nixpkgs.lib.extend (_: _: {
        dotfiles = dotfilesLib;
      });
    in
    {
      lib = flakeLib;
      darwinConfigurations = {
        macbook = dotfilesLib.mkHost (import ./hosts/macbook);
      };
      nixosConfigurations = {
        wsl = dotfilesLib.mkHost (import ./hosts/wsl);
      };
      homeConfigurations = {
        zanelu-macbook = dotfilesLib.mkHome (import ./hosts/macbook);
      };
    };
}

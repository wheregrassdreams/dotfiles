{ config, lib, pkgs, system, isDarwin, inputs, ... }:

let
  cfg = config.modules.dev;
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
  fenix = inputs.fenix;
in {
  options.modules.dev.enable = lib.mkEnableOption "Development tools configuration";

  config = lib.mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true;
        silent = true;
        nix-direnv.enable = true;
      };
      bun = {
        enable = true;
        enableGitIntegration = true;
        package = pkgs-unstable.bun;
      };
      k9s.enable = true;

      go = {
        enable = true;
        packages = {};

        env.GOPATH = ".go";
        env.GOBIN = ".local/bin";
        env.GOPRIVATE = [
          "*.xiaoe-tools.com"
        ];

      };
    };
    home = {
      packages = with pkgs; [
        sqlite
        alejandra
        deadnix
        nil
        nixd
        nixfmt-rfc-style
        nixpkgs-fmt
        statix
        (python313.withPackages (ps: [ ps.tkinter ]))
        # go
        nodejs
        lua
        luarocks
        postgresql_15
        redis
        hurl
        pipx
        pnpm
        sbcl
        uv
        zig
        (fenix.packages.${system}.stable.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rust-src"
          "rustfmt"
        ])
      ] ++ lib.optionals (pkgs ? kafka) [ kafka ]
        ++ lib.optionals (pkgs ? mysql) [ mysql ];
      sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.go/bin"
      ];
      sessionVariables = {
        NODE_COMPILE_CACHE = "$HOME/.cache/nodejs-compile-cache";
        # GOPATH = "$HOME/.go";
        # GOBIN = "$HOME/.go/bin";
        GOMODCACHE = "$HOME/.go/pkg/mod";
        GOCACHE = "$HOME/.cache/go-build";
      } // lib.optionalAttrs isDarwin {
        LIBRARY_PATH = "${pkgs.libiconv}/lib:$LIBRARY_PATH";
      };
    };
  };
}

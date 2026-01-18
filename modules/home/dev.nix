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
      bun = {
        enable = true;
        enableGitIntegration = true;
        package = pkgs-unstable.bun;
      };
      k9s.enable = true;

      go = {
        enable = true;
        packages = {};
        env = {
          GOPATH = "${config.home.homeDirectory}/.go";
          GOBIN = "${config.home.homeDirectory}/.go/bin";
          GOMODCACHE = "${config.home.homeDirectory}/.go/pkg/mod";
          GOCACHE = "${config.home.homeDirectory}/.cache/go-build";
          GOPRIVATE = [
            "*.xiaoe-tools.com"
          ];
        };

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
        (python313.withPackages (ps: [ ps.httpx ]))
        # go
        nodejs
        lua
        luarocks
        postgresql_15
        redis
        hurl
        # pipx
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
          "rust-analyzer"
        ])
      ] ++ lib.optionals (pkgs ? kafka) [ kafka ]
        ++ lib.optionals (pkgs ? mysql) [ mysql ];
      sessionPath = [
        "$HOME/.cargo/bin"
        "$HOME/.go/bin"
      ];
      sessionVariables = {
        NODE_COMPILE_CACHE = "${config.home.homeDirectory}/.cache/nodejs-compile-cache";
      } // lib.optionalAttrs isDarwin {
        LIBRARY_PATH = "${pkgs.libiconv}/lib:$LIBRARY_PATH";
      };
    };
  };
}

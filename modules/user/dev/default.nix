{ dotfilesLib, config, lib, pkgs, inputs, system, isDarwin, ... }@ctx:
dotfilesLib.domain ctx {

  namespace = "dotfiles.dev";
  description = "development environment";

  base = ./common.nix;

  features = {
    lua = {
      description = "Lua development tools";
      module = ./lua.nix;
    };
    nix = {
      description = "Nix development tools";
      module = ./nix.nix;
    };
    go = {
      description = "Go development tools";
      module = ./go.nix;
    };
    javascript = {
      description = "JavaScript development tools";
      module = ./javascript.nix;
    };
    rust = {
      description = "Rust development tools";
      module = ./rust.nix;
    };
    clang = {
      description = "C and C++ development tools";
      settings = {
        opengl = {
          enable = lib.mkEnableOption "OpenGL development environment" // { default = true; };
        };
      };
      module = ./clang.nix;
    };
    haskell = {
      description = "Haskell development tools";
      module = ./haskell.nix;
    };
    python = {
      description = "Python development tools";
      settings = {
        suite = lib.mkOption {
          type = lib.types.enum [ "minimal" "full" ];
          default = "minimal";
        };
      };
      module = ./python.nix;
    };
  };
}

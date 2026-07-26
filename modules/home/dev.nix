{ config, lib, pkgs, system, isDarwin, inputs, ... }:

let
  cfg = config.features.dev-common;
in {
  options.features.dev-common.enable = lib.mkEnableOption "Shared development tools";

  config = lib.mkIf cfg.enable {
    programs.k9s.enable = true;
    home = {
      packages = with pkgs; [
        cmake
        glfw
        neovim
        sqlite
        # ghc
        # haskell-language-server
        # go
        lua
        luarocks

        # 替换成docker
        # postgresql_15
        # redis

        hurl
        # pipx
        sbcl
        uv
      ];
      sessionVariables = lib.optionalAttrs isDarwin {
        LIBRARY_PATH = "${pkgs.libiconv}/lib:$LIBRARY_PATH";
      };
    };
  };
}

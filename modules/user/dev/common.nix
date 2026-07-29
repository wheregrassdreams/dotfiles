{ pkgs, lib, isDarwin, ... }:
{
  programs.k9s.enable = true;
  home = {
    packages = with pkgs; [ neovim sqlite  sbcl uv ];
    sessionVariables = lib.optionalAttrs isDarwin {
      LIBRARY_PATH = "${pkgs.libiconv}/lib:$LIBRARY_PATH";
    };
  };
}

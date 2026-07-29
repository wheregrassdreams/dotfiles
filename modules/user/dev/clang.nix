{ lib, pkgs, feature, ... }: {
  home.packages = with pkgs; [
    clang-tools
    llvmPackages.clang
    cmake
  ] ++ lib.optionals feature.opengl.enable [
    glfw
  ];
}

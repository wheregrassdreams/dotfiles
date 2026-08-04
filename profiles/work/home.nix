{ config, lib, pkgs, ... }:
let workDir = config.my.paths.personal.work;
in {
  programs.git.includes = [{ condition = "gitdir:${workDir}/"; path = "${workDir}/.gitconfig"; }];
  programs.go.env.GOPRIVATE = [ "*.xiaoe-tools.com" ];
  programs.bash.initExtra = lib.optionalString pkgs.stdenv.isDarwin ''ulimit -s 65500'';
  programs.zsh.initContent = lib.mkAfter (lib.optionalString pkgs.stdenv.isDarwin ''ulimit -s 65500'');
}

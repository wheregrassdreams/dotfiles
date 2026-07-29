{ lib, pkgs, ... }: {
  programs.git.includes = [{ condition = "gitdir:~/Work/"; path = "~/Work/.gitconfig"; }];
  programs.go.env.GOPRIVATE = [ "*.xiaoe-tools.com" ];
  programs.bash.initExtra = lib.optionalString pkgs.stdenv.isDarwin ''ulimit -s 65500'';
  programs.zsh.initContent = lib.mkAfter (lib.optionalString pkgs.stdenv.isDarwin ''ulimit -s 65500'');
}

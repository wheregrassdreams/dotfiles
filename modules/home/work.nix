{ pkgs, lib, config, ... }:
let
  cfg = config.features.work;
  initContent = lib.optionalString pkgs.stdenv.isDarwin # sh
    ''
      # Workaround for linker errors like https://github.com/nammayatri/nammayatri/blob/49b26c595681b68536f0357884c82766047805b1/Backend/README.md?plain=1#L97-L103
      # see also: <https://github.com/juspay/nixone/issues/34>
      ulimit -s 65500
    '';
in
{
  options.features.work.enable = lib.mkEnableOption "Work-specific development and access rules";
  config = lib.mkIf cfg.enable {
  programs = {
    bash.initExtra = initContent;
    zsh = {
      inherit initContent;
    };
    go.env.GOPRIVATE = [ "*.xiaoe-tools.com" ];
  };
  home.file.".ssh/config".text = lib.mkAfter ''

    Host homelab
    HostName homelab.tail50e8c0.ts.net
    User zane

    Host workbench.homelab dev.homelab
    HostName homelab.tail50e8c0.ts.net
    User dev
    Port 2223
    ForwardAgent yes
  '';
  programs.git.includes = [ {
    condition = "gitdir:~/Work/";
    path = "~/Work/.gitconfig";
  } ];
  };
}

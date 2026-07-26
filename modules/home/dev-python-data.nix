{ config, lib, pkgs, ... }:
let cfg = config.features.dev-python-data;
in {
  options.features.dev-python-data.enable = lib.mkEnableOption "Python data development tools";
  config = lib.mkIf cfg.enable {
    home.packages = [ (pkgs.python313.withPackages (ps: [ ps.httpx ps.pdfplumber ps.openpyxl ps.polars ps.pymysql ps.pypika ])) ];
  };
}

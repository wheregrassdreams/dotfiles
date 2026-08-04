{ pkgs, feature, ... }:
let
  python = pkgs.python313;
  data = pkgs.python313.withPackages (ps: with ps; [ httpx pdfplumber openpyxl polars pymysql pypika ]);
in {
  home.packages = with pkgs; [
    (if feature.suite == "full" then data else python)
    uv
    ruff
    pyright
  ];
}

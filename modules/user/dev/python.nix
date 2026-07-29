{ pkgs, feature, ... }:
let
  base = with pkgs; [ python313 uv ruff pyright ];
  data = pkgs.python313.withPackages (ps: with ps; [ httpx pdfplumber openpyxl polars pymysql pypika ]);
in {
  home.packages = base ++ pkgs.lib.optionals (feature.suite == "full") [ data ];
}

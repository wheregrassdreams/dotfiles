{ pkgs, ... }: {
  programs = {
    ripgrep.enable = true;
    jq.enable = true;
    fd = {
      enable = true;
      ignores = [ ".git/" "node_modules/" "venv/" "site-packages/" ".DS_Store" ];
    };
  };
  home.packages = with pkgs; [ yq grex quicktype csvkit];
}

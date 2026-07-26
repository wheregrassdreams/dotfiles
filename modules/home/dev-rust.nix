{ config, lib, inputs, system, ... }:
let cfg = config.features.dev-rust;
in {
  options.features.dev-rust.enable = lib.mkEnableOption "Rust development tools";
  config = lib.mkIf cfg.enable {
    home.packages = [ (inputs.fenix.packages.${system}.stable.withComponents [ "rustc" "cargo" "clippy" "rust-src" "rustfmt" "rust-analyzer" ]) ];
    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}

{ inputs, system, ... }: {
  home.packages = [ (inputs.fenix.packages.${system}.stable.withComponents [ "rustc" "cargo" "clippy" "rust-src" "rustfmt" "rust-analyzer" ]) ];
  home.sessionPath = [ "$HOME/.cargo/bin" ];
}

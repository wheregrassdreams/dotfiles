{ inputs, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      treefmt = inputs.treefmt-nix.lib.evalModule pkgs ../../treefmt.nix;
      preCommit = inputs.pre-commit-hooks.lib.${system}.run {
        src = ../../.;
        hooks = {
          check-added-large-files.enable = true;
          check-merge-conflicts.enable = true;
          check-symlinks.enable = true;
          deadnix.enable = true;
          end-of-file-fixer.enable = true;
          nixfmt-rfc-style.enable = true;
          shellcheck.enable = true;
          trim-trailing-whitespace.enable = true;
        };
      };
    in
    {
      formatter = treefmt.config.build.wrapper;
      packages.nix-fast-build = inputs.nix-fast-build.packages.${system}.default;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          deadnix
          just
          nixd
          nixfmt-rfc-style
          pre-commit
          shellcheck
          shfmt
          sops
          statix
          inputs.nix-fast-build.packages.${system}.default
        ];
        shellHook = preCommit.shellHook;
      };
    };
}

## New layout recap

1. `lib/mksystem.nix` now drives flake outputs; each host is referenced by name and loads:
   - `hosts/<name>/system.nix` (the former `default.nix`)
   - `hosts/<name>/home.nix` (new shim importing `modules/default.nix`)
   - shared modules under `modules/{common,nixos,darwin,home}`

2. Shared NixOS logic lives in `modules/nixos.nix`; macOS logic is in `modules/darwin.nix`; global overlays/options live in `modules/common.nix`; home-manager glue lives in `modules/home.nix`.
3. Secrets are provided via `modules/secrets-stub.nix` so every host/home module loads the same stub.
4. User-specific configuration now lives under `users/<user>/(nixos|darwin).nix` plus a `home-manager.nix` entry; the home module imports each user file so host builds can share module flags.
5. Flake outputs reference `lib/mksystem.nix`; host-specific `system.nix` files now only re-export their existing `*.nix` fragments (e.g., `hosts/desktop/system.nix` just lists `imports`), and `hosts/<name>/home.nix` pulls in the shared module tree.
6. The per-host fragments (`boot.nix`, `networking.nix`, etc.) live under `modules/hosts/<name>/` so each host folder only keeps a minimal `system.nix`/`home.nix` entrypoint that imports the wrapper module.

## Remaining work

- Move per-host fragments (`hosts/<name>/*.nix`) into permanent modules under `modules/nixos/host/` or similar if you want to reuse pieces across hosts.  
- Once migration completes, delete the old `hosts/<name>/*` helpers that are duplicated by the shared modules.  
- Keep the new `modules/hosts/<name>.nix` wrappers as the canonical entrypoint for host fragments so they can be reused across systems before the host-specific manifest is reduced to a single `import` line.
- Update documentation (e.g., `README.md`) to describe how to add a new host using `lib/mksystem.nix`.

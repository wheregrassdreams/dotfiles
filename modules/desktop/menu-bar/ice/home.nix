{ ... }: {
  # Ice has no Home Manager payload, but the profile uses one app selection
  # vocabulary for its system and home halves.
  imports = [ ../default.nix ];
}

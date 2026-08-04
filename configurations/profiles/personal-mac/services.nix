{ ... }: {
  # Services on this machine are managed outside of Nix unless explicitly
  # enabled here with a local lifecycle mode.
  my.services.defaultMode = "external";
}

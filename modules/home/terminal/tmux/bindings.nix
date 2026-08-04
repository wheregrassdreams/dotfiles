{ lib, ... }:
let
  data = import ./bindings-data.nix { };
  render = table: binding:
    "bind -T ${table} ${lib.optionalString (binding.repeat or false) "-r "}${binding.key} ${binding.command}";
  keys = bindings: map (binding: binding.key) bindings;
in
{
  assertions = [
    {
      assertion = builtins.length (keys data.prefix) == builtins.length (lib.unique (keys data.prefix));
      message = "tmux prefix bindings contain duplicate keys";
    }
    {
      assertion = builtins.length (keys data.copyMode) == builtins.length (lib.unique (keys data.copyMode));
      message = "tmux copy-mode bindings contain duplicate keys";
    }
  ];

  programs.tmux.extraConfig = lib.mkAfter (lib.concatMapStringsSep "\n" (render "prefix") data.prefix);
}

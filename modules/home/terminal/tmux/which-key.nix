# Deliberately not imported by default. This is a prepared enhancement which
# derives future menu entries from bindings-data.nix without changing tmux.
{ pkgs, ... }:
let
  data = import ./bindings-data.nix { };
  menu = {
    keybindings.prefix_table = "Space";
    items = map (binding: {
      key = binding.key;
      name = binding.command;
      command = binding.command;
    }) data.prefix;
  };
  yaml = (pkgs.formats.yaml { }).generate "tmux-which-key.yaml" menu;
in
{
  # Keep the generated data reachable for a future explicit opt-in without
  # loading the plugin or adding a user-facing option today.
  _module.args.tmuxWhichKeyYaml = yaml;
}

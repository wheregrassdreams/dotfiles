{ config, lib, ... }: {
  config = lib.mkIf config.my.desktop.keymap.karabiner.enable {
    my.terminal.tmux.inputMethod.command = "${config.my.homebrew.brewPrefix}/bin/im-select";
  };
}

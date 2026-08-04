{ config, lib, ... }: {
  config = lib.mkIf config.dotfiles.desktop.keymap.karabiner.enable {
    dotfiles.terminal.tmux.inputMethod.command = "${config.dotfiles.homebrew.brewPrefix}/bin/im-select";
  };
}

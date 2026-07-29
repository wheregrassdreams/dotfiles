{ config, lib, ... }: {
  config = lib.mkIf config.dotfiles.desktop.keymap.karabiner.enable {
    dotfiles.terminal.tmux.inputMethod.command = "/opt/homebrew/bin/im-select";
  };
}

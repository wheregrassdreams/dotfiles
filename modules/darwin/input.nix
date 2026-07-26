{ userName, ... }: {
  imports = [ ./karabiner ];
  homebrew.brews = [ "daipeihust/tap/im-select" ];
  home-manager.users.${userName}.programs.tmux.extraConfig = ''
    set -g @tmux-input-method-command '/opt/homebrew/bin/im-select'
    set -g @tmux-input-method-layout 'com.apple.keylayout.ABC'
  '';
}

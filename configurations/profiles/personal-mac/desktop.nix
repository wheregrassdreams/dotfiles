{ ... }:
{
  my.gui = {
    browser = {
      default = "safari";
      chrome.enable = true;
      zen.enable    = false;
    };

    terminal = {
      ghostty.enable = true;
      kitty.enable   = true;
    };

    keymap = {
      karabiner.enable = true;
      # imSelector.enable = true;
    };

    menuBar.ice.enable = false; # ice 不兼容macos26
    workspace.enable = true;
  };
}

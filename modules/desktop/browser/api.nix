{ config, lib, ... }:
{
  options.dotfiles.desktop.browser = {
    chrome.enable = lib.mkEnableOption "Google Chrome";
    zen.enable = lib.mkEnableOption "Zen Browser";
    default = lib.mkOption {
      type = lib.types.enum [ "safari" "chrome" "zen" ];
      default = "safari";
      description = "macOS default browser";
    };
  };

  config.assertions = [
    {
      assertion = config.dotfiles.desktop.browser.default != "chrome" || config.dotfiles.desktop.browser.chrome.enable;
      message = "dotfiles.desktop.browser.default is chrome, but Chrome is disabled";
    }
    {
      assertion = config.dotfiles.desktop.browser.default != "zen" || config.dotfiles.desktop.browser.zen.enable;
      message = "dotfiles.desktop.browser.default is zen, but Zen is disabled";
    }
  ];
}

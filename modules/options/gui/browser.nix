{ config, lib, ... }:
{
  options.my.gui.browser = {
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
      assertion = config.my.gui.browser.default != "chrome" || config.my.gui.browser.chrome.enable;
      message = "my.gui.browser.default is chrome, but Chrome is disabled";
    }
    {
      assertion = config.my.gui.browser.default != "zen" || config.my.gui.browser.zen.enable;
      message = "my.gui.browser.default is zen, but Zen is disabled";
    }
  ];
}

{ config, lib, ... }:
let
  locationVariable = name:
    "DOTFILES_PATH_${lib.toUpper (lib.replaceStrings [ "-" "." "/" " " ] [ "_" "_" "_" "_" ] name)}";
  names = map locationVariable (builtins.attrNames config.my.paths.personal);
in
{
  options.my.paths = {
    home = lib.mkOption { type = lib.types.str; readOnly = true; };
    dotfiles = lib.mkOption { type = lib.types.str; readOnly = true; };
    localBin = lib.mkOption { type = lib.types.str; readOnly = true; };
    xdg = {
      config = lib.mkOption { type = lib.types.str; readOnly = true; };
      data = lib.mkOption { type = lib.types.str; readOnly = true; };
      cache = lib.mkOption { type = lib.types.str; readOnly = true; };
      state = lib.mkOption { type = lib.types.str; readOnly = true; };
    };
    personal = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Named personal and business locations";
    };
  };

  config.assertions = [{
    assertion = builtins.length names == builtins.length (lib.unique names);
    message = "my.paths.personal contains names that map to the same DOTFILES_PATH_* environment variable";
  }];
}

{ lib }:
args@{
  config,
  ...
}:
{
  namespace,
  description,
  features ? { },
  settings ? { },
  base ? null,
  apiOnly ? false,
}:
let
  path = lib.splitString "." namespace;
  cfg = lib.getAttrFromPath path config;
  moduleConfig = module: extraArgs:
    let
      imported = import module;
      result = if builtins.isFunction imported then imported (args // extraArgs) else imported;
    in result.config or result;
  featureOption = feature:
    if feature ? settings then
      lib.mkOption {
        type = lib.types.submodule {
          options = feature.settings // {
            enable = lib.mkEnableOption feature.description;
          };
        };
        default = { };
      }
    else
      lib.mkEnableOption feature.description;
  featureEnabled = name: feature:
    cfg.enable && (if feature ? settings then name.enable else name);
  isGroup = item: item._type or null == "dotfiles-feature-group";
  optionTree = items:
    lib.mapAttrs (_: item:
      if isGroup item then
        lib.mkOption {
          type = lib.types.submodule { options = optionTree item.children; };
          default = { };
        }
      else
        featureOption item
    ) items;
  configTree = prefix: items:
    lib.concatMap (name:
      let
        item = items.${name};
        itemPath = prefix ++ [ name ];
        itemConfig = lib.getAttrFromPath itemPath cfg;
      in if isGroup item then
        configTree itemPath item.children
      else
        lib.optional (item ? module) (lib.mkIf (featureEnabled itemConfig item) (
          moduleConfig item.module { feature = itemConfig; }
        ))
    ) (builtins.attrNames items);
in {
  options = lib.setAttrByPath path (settings // {
    enable = lib.mkEnableOption description;
  } // optionTree features);

  config = if apiOnly then { } else lib.mkMerge (
    lib.optional (base != null) (lib.mkIf cfg.enable (moduleConfig base { }))
    ++ configTree [ ] features
  );
}

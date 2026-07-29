{ lib }:
args@{
  config,
  ...
}:
{
  namespace,
  description,
  features ? { },
  groups ? { },
  agents ? { },
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
    cfg.enable && (if feature ? settings then cfg.${name}.enable else cfg.${name});
  agentOption = agent:
    lib.mkOption {
      type = lib.types.submodule {
        options = lib.mapAttrs (_: surface:
          lib.mkEnableOption surface.description
        ) agent.surfaces;
      };
      default = { };
    };
  groupOption = group:
    lib.mkOption {
      type = lib.types.submodule {
        options = lib.mapAttrs (_: feature: featureOption feature) group.features;
      };
      default = { };
    };
  featureConfig = lib.mapAttrsToList (name: feature:
    lib.mkIf (featureEnabled name feature) (
      moduleConfig feature.module { feature = cfg.${name}; }
    )
  ) features;
  groupConfig = lib.concatMap (groupName:
    let group = groups.${groupName};
    in lib.mapAttrsToList (featureName: feature:
      lib.mkIf (cfg.enable && (if feature ? settings
        then cfg.${groupName}.${featureName}.enable
        else cfg.${groupName}.${featureName})) (
        moduleConfig feature.module { feature = cfg.${groupName}.${featureName}; }
      )
    ) group.features
  ) (builtins.attrNames groups);
  agentConfig = lib.concatMap (agentName:
    let agent = agents.${agentName};
    in lib.mapAttrsToList (surfaceName: surface:
      lib.mkIf (cfg.enable && cfg.${agentName}.${surfaceName}) (
        lib.optionalAttrs (surface ? module) (
          moduleConfig surface.module {
            agent = cfg.${agentName};
            surface = cfg.${agentName}.${surfaceName};
          }
        )
      )
    ) agent.surfaces
  ) (builtins.attrNames agents);
in {
  options = lib.setAttrByPath path (settings // {
    enable = lib.mkEnableOption description;
  } // lib.mapAttrs (_: feature: featureOption feature) features
    // lib.mapAttrs (_: group: groupOption group) groups
    // lib.mapAttrs (_: agent: agentOption agent) agents);

  config = lib.mkIf (!apiOnly) (lib.mkMerge (
    lib.optional (base != null) (lib.mkIf cfg.enable (moduleConfig base { }))
    ++ featureConfig
    ++ groupConfig
    ++ agentConfig
  ));
}

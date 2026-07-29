{ config, lib, ... }:
let
  cfg = config.dotfiles.data;
  preservationType = lib.types.enum [
    "durable"
    "rebuildable"
    "review"
  ];
  replicationType = lib.types.enum [
    "none"
    "sync"
    "export-required"
  ];
  restoreType = lib.types.enum [
    "copy-tree"
    "import-export"
    "rebuild"
    "manual"
  ];
  lifecycleOptions = {
    preservation = lib.mkOption {
      type = preservationType;
      description = "how important the data is to retain";
    };
    replication = lib.mkOption {
      type = replicationType;
      description = "how the data must be copied before it can be protected";
    };
    restore = lib.mkOption {
      type = restoreType;
      description = "the recovery procedure category for the data";
    };
  };
  itemType = lib.types.submodule ({ ... }: {
    options = lifecycleOptions // {
      source = {
        type = lib.mkOption {
          type = lib.types.enum [ "path" "service" ];
          description = "whether the data originates from a file tree or a service";
        };
        path = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "source path for path-backed data";
        };
        service = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "logical service name for service-backed data";
        };
      };
    };
  });
  serviceTemplateType = lib.types.submodule ({ ... }: {
    options = lifecycleOptions;
  });
  itemAssertions = lib.concatMap (name:
    let item = cfg.items.${name}; in [
      {
        assertion = item.source.type != "path" || (item.source.path != null && item.source.service == null);
        message = "dotfiles.data.items.${name}: path sources require source.path and forbid source.service";
      }
      {
        assertion = item.source.type != "service" || (item.source.service != null && item.source.path == null);
        message = "dotfiles.data.items.${name}: service sources require source.service and forbid source.path";
      }
      {
        assertion = item.replication != "export-required" || item.source.type == "service";
        message = "dotfiles.data.items.${name}: export-required replication requires a service source";
      }
      {
        assertion = item.source.type != "service" || item.replication == "export-required";
        message = "dotfiles.data.items.${name}: service sources require export-required replication";
      }
      {
        assertion = item.replication != "export-required" || item.restore == "import-export";
        message = "dotfiles.data.items.${name}: export-required replication requires import-export restoration";
      }
      {
        assertion = item.restore != "import-export" || item.replication == "export-required";
        message = "dotfiles.data.items.${name}: import-export restoration requires export-required replication";
      }
    ]) (builtins.attrNames cfg.items);
  serviceTemplateAssertions = lib.concatMap (name:
    let template = cfg.serviceTemplates.${name}; in [
      {
        assertion = template.replication == "export-required";
        message = "dotfiles.data.serviceTemplates.${name}: service data requires export-required replication";
      }
      {
        assertion = template.restore == "import-export";
        message = "dotfiles.data.serviceTemplates.${name}: service data requires import-export restoration";
      }
    ]) (builtins.attrNames cfg.serviceTemplates);
in {
  options.dotfiles.data = {
    items = lib.mkOption {
      type = lib.types.attrsOf itemType;
      default = { };
      description = "Declared data items and their recovery contracts";
    };
    serviceTemplates = lib.mkOption {
      type = lib.types.attrsOf serviceTemplateType;
      default = { };
      description = "Recovery contracts that apply when a named service later owns local data";
    };
  };

  config.assertions = itemAssertions ++ serviceTemplateAssertions;
}

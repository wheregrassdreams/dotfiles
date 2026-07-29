{ config, ... }:
let paths = config.dotfiles.paths;
in{
  dotfiles.data = {
    items.notes = {
      source = {
        type = "path";
        path = paths.personal.notes;
      };
      preservation = "durable";
      replication = "sync";
      restore = "copy-tree";
    };

    # serviceTemplates = {
    #   mysql = {
    #     preservation = "durable";
    #     replication = "export-required";
    #     restore = "import-export";
    #   };
    #   postgres = {
    #     preservation = "durable";
    #     replication = "export-required";
    #     restore = "import-export";
    #   };
    #   redis = {
    #     preservation = "durable";
    #     replication = "export-required";
    #     restore = "import-export";
    #   };
    };
  };
}

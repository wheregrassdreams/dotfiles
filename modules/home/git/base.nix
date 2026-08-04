{ config, lib, pkgs, identity, ... }:
{
  config = lib.mkIf config.my.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = identity.fullname;
          email = identity.email;
        };

        core.pager = "delta";
        interactive.diffFilter = "delta --color-only --features=interactive";

        delta = {
          features = "decorations";
          syntax-theme = "OneHalfDark";
          line-numbers = true;
          side-by-side = false;
          navigate = true;
        };
        "delta \"interactive\"".keep-plus-minus-markers = false;
        "delta \"decorations\"" = {
          commit-decoration-style = "blue ol";
          commit-style = "raw";
          file-style = "omit";
          hunk-header-decoration-style = "blue box";
          hunk-header-file-style = "red";
          hunk-header-line-number-style = "#067a00";
          hunk-header-style = "file line-number syntax";
        };

        diff = {
          tool = "nvimdiff";
          colorMoved = "default";
        };

        branch.sort = "-committerdate";
        fetch.prune = true;
        merge.conflictstyle = "diff3";
        push = {
          autoSetupRemote = true;
          followTags = true;
        };
        rebase = {
          autoStash = true;
          updateRefs = true;
        };
        rerere.enabled = true;
      };
    };

    home.packages = with pkgs; [
      git
      delta
      git-filter-repo
      git-lfs
    ];
  };
}

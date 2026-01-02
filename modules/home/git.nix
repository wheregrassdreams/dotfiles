{ config, pkgs, ... }:

{
    programs = {
        git = {
            enable = true;
            settings = {
                user = {
                    name = config.me.fullname;
                    email = config.me.email;
                };

                core = {
                    pager = "delta";
                };

                interactive = {
                    diffFilter = "delta --color-only --features=interactive";
                };

                delta = {
                    features = "decorations";
                    syntax-theme = "OneHalfDark";
                    line-numbers = true;
                    side-by-side = false;
                    navigate = true;
                };
                "delta \"interactive\"" = {
                    keep-plus-minus-markers = false;
                };
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

                push.autoSetupRemote = true;
            };
        };

        lazygit.enable = true;

    };

    home.shellAliases = {
        lg = "lazygit";
    };

    # delta 本体由 nix / brew 提供
    home.packages = with pkgs; [
        git
        delta
        gh
        git-filter-repo
        git-lfs
    ];

}

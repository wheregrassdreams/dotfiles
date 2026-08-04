{ ... }:
{
  programs = {
    nix-search-tv = {
      enable = true;
      enableTelevisionIntegration = true;
    };

    television = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        tick_rate = 50;
        default_channel = "files";
        shell_integration = {
          channel_triggers = {
            files = [ "bat" "cat" "cp" "less" "mv" "rm" "touch" "vim" ];
            git-diff = [ "git add" "git restore" ];
            git-log = [ "git log" "git show" ];
            man = [ "man" ];
            nixpkgs = [ "nix shell" ];
          };
          keybindings = {
            smart_autocomplete = "ctrl-o";
            command_history = "ctrl-t";
          };
        };
      };
      channels = {
        files = {
          metadata = {
            name = "files";
            description = "Select files and directories";
            requirements = [ "fd" "bat" ];
          };
          source.command = [ "fd -t f" "fd -t f -H" ];
          preview.command = "bat -n --color=always '{}'";
          preview.env.BAT_THEME = "ansi";
          keybindings = {
            shortcut = "f1";
            f12 = "actions:edit";
            ctrl-up = "actions:goto_parent_dir";
          };
          actions = {
            edit = {
              description = "Open the selected entry in the configured editor";
              command = "$${EDITOR:-vim} '{}'";
              mode = "execute";
            };
            goto_parent_dir = {
              description = "Re-open the files channel in the parent directory";
              command = "tv files ..";
              mode = "execute";
            };
          };
        };

        git-diff = {
          metadata = {
            name = "git-diff";
            description = "Select files changed from HEAD";
            requirements = [ "git" ];
          };
          source.command = "git diff --name-only HEAD";
          preview.command = "git diff HEAD --color=always -- '{}'";
        };

        git-log = {
          metadata = {
            name = "git-log";
            description = "Select Git commits";
            requirements = [ "git" ];
          };
          source = {
            command = "git log --graph --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --color=always";
            output = "{strip_ansi|split: :1}";
            ansi = true;
          };
          preview.command = "git show -p --stat --pretty=fuller --color=always '{strip_ansi|split: :1}' | head -n 1000";
        };

        man-pages = {
          metadata = {
            name = "man-pages";
            description = "Browse manual pages";
            requirements = [ "apropos" "man" "col" ];
          };
          source.command = "apropos .";
          preview = {
            command = "man '{0}' | col -bx";
            env.MANWIDTH = "80";
          };
          keybindings.enter = "actions:open";
          actions.open = {
            description = "Open the selected manual page";
            command = "man '{0}'";
            mode = "execute";
          };
          ui.preview_panel.header = "{0}";
        };
      };
    };
  };
}

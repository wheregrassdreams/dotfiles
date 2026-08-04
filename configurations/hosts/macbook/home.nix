{ config, lib, identity, ... }:
{
  imports = [
    ../../../modules/home
    ../../../modules/home/homebrew
    ../../../modules/home/gui/home.nix
    ../../../modules/home/data/home.nix
    ../../../modules/home/services
    ../../../modules/home/connectivity/tailscale/home.nix
    ../../profiles/personal-mac/home.nix
    ../../profiles/personal-mac/homebrew.nix
    ../../profiles/personal-mac/ai-home.nix
    ../../profiles/personal-mac/desktop.nix
    ../../profiles/personal-mac/data.nix
    ../../profiles/personal-mac/connectivity.nix
    ../../profiles/personal-mac/services.nix
    ../../profiles/work/home.nix
    ../../profiles/homelab/home.nix
  ];

  config = lib.mkMerge [
    {
      home = {
        stateVersion = "25.11";
        enableNixpkgsReleaseCheck = false;
      };

      my = {
        identity = identity;
        homebrew.brewPrefix = "/opt/homebrew";
        connectivity.tailscale.host = "homelab.tail50e8c0.ts.net";
        paths.personal = {
          work = "${config.home.homeDirectory}/Work";
          notes = "${config.home.homeDirectory}/Workspace/notes";
        };
      };

      targets.darwin.defaults = {
        ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;

        "com.apple.finder" = {
          AppleShowAllFiles = true;
          CreateDesktop = false;
          FXDefaultSearchScope = "SCcf";
          FXPreferredViewStyle = "Nlsv";
          FXRemoveOldTrashItems = true;
          NewWindowTarget = "Desktop";
          ShowExternalHardDrivesOnDesktop = false;
          ShowHardDrivesOnDesktop = false;
          ShowMountedServersOnDesktop = false;
          ShowRemovableMediaOnDesktop = false;
        };
      };
    }

    (lib.mkIf config.my.gui.menuBar.ice.enable {
      targets.darwin.defaults."com.jordanbaird.Ice" = {
        AutoRehide = true;
        CanToggleAlwaysHiddenSection = true;
        EnableAlwaysHiddenSection = true;
        IceBarLocation = 0;
        ItemSpacingOffset = 0.0;
        RehideInterval = 15;
        RehideStrategy = 0;
        ShowAllSectionsOnUserDrag = true;
        ShowIceIcon = true;
        ShowOnClick = true;
        ShowOnHover = false;
        ShowOnHoverDelay = 0.2;
        ShowOnScroll = true;
        ShowSectionDividers = false;
        TempShowInterval = 15;
        UseIceBar = true;
        SUAutomaticallyUpdate = false;
        SUEnableAutomaticallyChecks = false;
      };
    })

    (lib.mkIf config.my.gui.keymap.karabiner.enable {
      my.terminal.tmux.inputMethod.command = "${config.my.homebrew.brewPrefix}/bin/im-select";
    })
  ];
}

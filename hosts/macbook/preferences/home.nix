{ config, lib, ... }:
{
  config = lib.mkMerge [
    {
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

    (lib.mkIf config.dotfiles.desktop.menuBar.ice.enable {
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

    # Intentionally disabled: Safari preferences remain documented but are not applied.
    # { targets.darwin.defaults."com.apple.Safari" = { ... }; }

    # Dock stays disabled. When enabled, keep its user-level defaults here and
    # apply entries through the Home Manager dock adapter.
    # { targets.darwin.defaults."com.apple.dock" = { ... }; }
  ];
}

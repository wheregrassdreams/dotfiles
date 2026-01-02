{ userName, ... }: {

  system = {
    primaryUser = userName;
    defaults = {
      ".GlobalPreferences" = {
        "com.apple.mouse.scaling" = -1.0;
      };
      # ActivityMonitor = {
      #   IconType = 5;
      #   OpenMainWindow = true;
      #   ShowCategory = 100;
      #   SortColumn = "CPUUsage";
      #   SortDirection = 0;
      # };
      # controlcenter = {
      #   AirDrop = false;
      #   BatteryShowPercentage = true;
      #   Bluetooth = false;
      #   Display = false;
      #   FocusModes = false;
      #   NowPlaying = false;
      #   Sound = false;
      # };
      # dock = {
      #   # Keep Dock visible on hover; avoid the "never show" delay.
      #   autohide = true;
      #   autohide-delay = 0.2;
      #   autohide-time-modifier = 0.5;
      #   expose-animation-duration = 0.5;
      #   launchanim = false;
      #   mineffect = "scale";
      #   minimize-to-application = true;
      #   mru-spaces = false;
      #   # Dock position (bottom).
      #   orientation = "bottom";
      #   persistent-apps = [];
      #   persistent-others = [];
      #   show-process-indicators = true;
      #   show-recents = false;
      #   static-only = true;
      #   tilesize = 48;
      #   wvous-bl-corner = 1;
      #   wvous-br-corner = 1;
      #   wvous-tl-corner = 1;
      #   wvous-tr-corner = 1;
      # };
      finder = {
        _FXShowPosixPathInTitle = true;  # show full path in finder title
        _FXSortFoldersFirst = true;
        _FXSortFoldersFirstOnDesktop = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Desktop";
        ShowPathbar = true; # show path bar
        ShowStatusBar = true; # show status bar
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = false;
      };
      # hitoolbox.AppleFnUsageType = "Do Nothing";
      # LaunchServices.LSQuarantine = false;
      # loginwindow = {
      #   DisableConsoleAccess = true;
      #   GuestEnabled = false;
      #   SHOWFULLNAME = false;
      #   PowerOffDisabledWhileLoggedIn = true;
      #   RestartDisabled = true;
      #   RestartDisabledWhileLoggedIn = true;
      #   ShutDownDisabled = true;
      #   ShutDownDisabledWhileLoggedIn = true;
      #   SleepDisabled = true;
      # };
      # menuExtraClock = {
      #   Show24Hour = true;
      #   ShowDate = 1;
      #   ShowDayOfWeek = false;
      # };
      # NSGlobalDomain = {
      #   "com.apple.mouse.tapBehavior" = 1;
      #   "com.apple.sound.beep.feedback" = 0;
      #   "com.apple.sound.beep.volume" = 0.0;
      #   "com.apple.springing.delay" = 0.0;
      #   "com.apple.springing.enabled" = false;
      #   "com.apple.trackpad.forceClick" = false;
      #   AppleEnableMouseSwipeNavigateWithScrolls = false;
      #   AppleEnableSwipeNavigateWithScrolls = false;
      #   AppleICUForce24HourTime = true;
      #   AppleInterfaceStyle = "Dark";
      #   AppleKeyboardUIMode = 3;
      #   AppleMeasurementUnits = "Centimeters";
      #   AppleMetricUnits = 1;
      #   ApplePressAndHoldEnabled = false;
      #   AppleShowAllExtensions = true;
      #   AppleShowAllFiles = true;
      #   AppleShowScrollBars = "Always";
      #   AppleSpacesSwitchOnActivate = false;
      #   AppleTemperatureUnit = "Celsius";
      #   AppleWindowTabbingMode = "manual";
      #   InitialKeyRepeat = 10;
      #   KeyRepeat = 1;
      #   NSAutomaticCapitalizationEnabled = false;
      #   NSAutomaticDashSubstitutionEnabled = false;
      #   NSAutomaticInlinePredictionEnabled = false;
      #   NSAutomaticPeriodSubstitutionEnabled = false;
      #   NSAutomaticQuoteSubstitutionEnabled = false;
      #   NSAutomaticSpellingCorrectionEnabled = false;
      #   NSAutomaticWindowAnimationsEnabled = false;
      #   NSDisableAutomaticTermination = true;
      #   NSNavPanelExpandedStateForSaveMode = true;
      #   NSNavPanelExpandedStateForSaveMode2 = true;
      #   NSTableViewDefaultSizeMode = 2;
      #   NSUseAnimatedFocusRing = false;
      #   NSWindowResizeTime = 0.0;
      #   NSWindowShouldDragOnGesture = false;
      #   PMPrintingExpandedStateForPrint = true;
      #   PMPrintingExpandedStateForPrint2 = true;
      # };
      # screencapture = {
      #   disable-shadow = true;
      #   include-date = true;
      #   location = "/Users/${userName}/Downloads";
      #   show-thumbnail = true;
      #   type = "png";
      # };
      # screensaver = {
      #   askForPassword = true;
      #   askForPasswordDelay = 0;
      # };
      # SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
      # spaces.spans-displays = false;
      # trackpad = {
      #   ActuationStrength = 0;
      #   Clicking = true;
      #   Dragging = false;
      #   FirstClickThreshold = 0;
      #   SecondClickThreshold = 0;
      #   TrackpadRightClick = true;
      #   TrackpadThreeFingerTapGesture = 0;
      # };
      # universalaccess = {
      #   reduceMotion = false;
      #   reduceTransparency = false;
      # };
      # WindowManager = {
      #   AppWindowGroupingBehavior = false;
      #   EnableStandardClickToShowDesktop = false; # Click wallpaper to reveal desktop
      #   EnableTiledWindowMargins = false;
      #   EnableTilingByEdgeDrag = false;
      #   EnableTilingOptionAccelerator = false;
      #   EnableTopTilingByEdgeDrag = false;
      #   GloballyEnabled = false;
      #   HideDesktop = true; # Do not hide itmes on desktop & stage manager
      #   StageManagerHideWidgets = true;
      #   StandardHideDesktopIcons = true;
      #   StandardHideWidgets = true;
      # };
      # CustomSystemPreferences = {
      #   "com.apple.BluetoothAudioAgent" = {
      #     "Apple Bitpool Max (editable)" = 80;
      #     "Apple Bitpool Min (editable)" = 80;
      #     "Apple Initial Bitpool (editable)" = 80;
      #     "Apple Initial Bitpool Min (editable)" = 80;
      #     "Negotiated Bitpool" = 80;
      #     "Negotiated Bitpool Max" = 80;
      #     "Negotiated Bitpool Min" = 80;
      #   };
      #   "com.apple.TimeMachine" = {
      #     DoNotOfferNewDisksForBackup = true;
      #   };
      #   "com.apple.DiskArbitration.diskarbitrationd" = {
      #     DADisableEjectNotification = true;
      #     AMDisableEjectNotification = true;
      #   };
      # };
      CustomUserPreferences = {
        # "com.apple.HIToolbox" = {
        #   # Caps Lock: tap to switch input source; hold for Caps Lock.
        #   AppleCapsLockPressAndHoldToggleOff = 0;
        #   AppleCapsLockSwitchesInputSource = true;
        # };
        # "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        #   TrackpadThreeFingerHorizSwipeGesture = 0;
        #   TrackpadThreeFingerVertSwipeGesture = 0;
        #   TrackpadFourFingerHorizSwipeGesture = 0;
        #   # Four-finger swipe up: Mission Control; swipe down: App Exposé.
        #   TrackpadFourFingerVertSwipeGesture = 2;
        #   TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;
        # };
        # "com.apple.AppleMultitouchTrackpad" = {
        #   TrackpadThreeFingerHorizSwipeGesture = 0;
        #   TrackpadThreeFingerVertSwipeGesture = 0;
        #   TrackpadFourFingerHorizSwipeGesture = 0;
        #   # Four-finger swipe up: Mission Control; swipe down: App Exposé.
        #   TrackpadFourFingerVertSwipeGesture = 2;
        #   TrackpadTwoFingerFromRightEdgeSwipeGesture = 0;
        # };
        # "com.apple.dock" = {
        #   # Enable system gestures for Mission Control and App Exposé.
        #   showMissionControlGestureEnabled = true;
        #   showAppExposeGestureEnabled = true;
        #   showDesktopGestureEnabled = false;
        #   showLaunchpadGestureEnabled = false;
        # };
        # "com.apple.Safari" = {
        #   AlwaysRestoreSessionAtLaunch = true;
        #   AutoOpenSafeDownloads = false;
        #   ShowStandaloneTabBar = false;
        #   TabCreationPolicy = 1;
        #   SearchProviderShortName = "DuckDuckGo";
        #   PrivateSearchProviderShortName = "DuckDuckGo";
        #   WBSLastPrivateSearchEngineStringExplicitlyChosenByUserKey = "com.duckduckgo";
        #   UniversalSearchEnabled = true;
        #   WarnAboutFraudulentWebsites = true;
        #   BlockStoragePolicy = 2;
        #   WBSPrivacyProxyAvailabilityTraffic = 33422572;
        #   ShowFullURLInSmartSearchField = true;
        #   NeverUseBackgroundColorInToolbar = false;
        #   EnableEnhancedPrivacyInPrivateBrowsing = true;
        #   EnableEnhancedPrivacyInRegularBrowsing = true;
        #   ShowFavoritesBar-v2 = false;
        #   DebugSnapshotsUpdatePolicy = 2;
        #   FindOnPageMatchesWordStartsOnly = false;
        #   SuppressSearchSuggestions = true;
        #   WebContinuousSpellCheckingEnabled = true;
        #   WebAutomaticSpellingCorrectionEnabled = false;
        #   InstallExtensionUpdatesAutomatically = true;
        # };
        # "com.apple.messageshelper.MessageController" = {
        #   SOInputLineSettings = {
        #     automaticEmojiSubstitutionEnablediMessage = false;
        #     automaticQuoteSubstitutionEnabled = false;
        #     continuousSpellCheckingEnabled = false;
        #   };
        # };
        # "com.apple.desktopservices" = {
        #   DSDontWriteNetworkStores = true;
        #   DSDontWriteUSBStores = true;
        # };
        # "com.apple.frameworks.diskimages" = {
        #   skip-verify = true;
        #   skip-verify-locked = true;
        #   skip-verify-remote = true;
        #   auto-mount-removable = false;
        #   auto-mount-notifications = false;
        # };
        # "com.apple.NetworkBrowser" = {
        #   BrowseAllInterfaces = true;
        # };
        "com.jordanbaird.Ice" = {
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
      };
    };
    keyboard = {
      enableKeyMapping = true;
      # NOTE: do NOT support remap capslock to both control and escape at the same time
      remapCapsLockToControl = false;  # remap caps lock to control, useful for emac users
      remapCapsLockToEscape  = false;   # remap caps lock to escape, useful for vim users
      nonUS.remapTilde = true;
    };
    startup.chime = false;
  };
}

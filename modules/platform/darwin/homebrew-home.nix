{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.homebrew;
  escapeRuby = value: lib.replaceStrings [ "\\" "\"" ] [ "\\\\" "\\\"" ] value;
  tapLine = tap:
    ''tap "${escapeRuby tap.name}"''
    + lib.optionalString tap.trusted ", trusted: true";
  brewfile = pkgs.writeText "Brewfile" (lib.concatStringsSep "\n" (
    lib.unique (map tapLine cfg.taps)
    ++ lib.unique (map (name: ''brew "${escapeRuby name}"'') cfg.brews)
    ++ lib.unique (map (name: ''cask "${escapeRuby name}"'') cfg.casks)
    ++ lib.mapAttrsToList (name: id: ''mas "${escapeRuby name}", id: ${toString id}'') cfg.masApps
  ) + "\n");
  brewSync = pkgs.writeShellScriptBin "brew-sync" ''
    set -eu

    brew=${lib.escapeShellArg "${cfg.brewPrefix}/bin/brew"}
    brewfile=${lib.escapeShellArg brewfile}
    auto_update=${if cfg.sync.autoUpdate then "1" else "0"}
    upgrade=${if cfg.sync.upgrade then "1" else "0"}
    cleanup=${lib.escapeShellArg cfg.sync.cleanup}

    usage() {
      echo "Usage: brew-sync [--update] [--upgrade] [--cleanup] [--zap]" >&2
    }

    while [ "$#" -gt 0 ]; do
      case "$1" in
        --update) auto_update=1 ;;
        --upgrade) upgrade=1 ;;
        --cleanup) cleanup=uninstall ;;
        --zap) cleanup=zap ;;
        -h|--help) usage; exit 0 ;;
        *) usage; exit 2 ;;
      esac
      shift
    done

    if [ ! -x "$brew" ]; then
      echo "Homebrew is not installed at ${cfg.brewPrefix}; run darwin-rebuild first." >&2
      exit 1
    fi

    if [ "$auto_update" -eq 1 ]; then
      "$brew" update
    else
      export HOMEBREW_NO_AUTO_UPDATE=1
    fi

    set -- bundle install --file="$brewfile"
    if [ "$upgrade" -eq 0 ]; then
      set -- "$@" --no-upgrade
    fi
    case "$cleanup" in
      none) ;;
      uninstall) set -- "$@" --force-cleanup ;;
      zap) set -- "$@" --force-cleanup --zap ;;
      *) echo "invalid cleanup mode: $cleanup" >&2; exit 2 ;;
    esac

    exec "$brew" "$@"
  '';
in {
  imports = [ ../../options/homebrew.nix ];

  config = lib.mkIf cfg.enable {
    xdg.configFile."homebrew/Brewfile".source = brewfile;
    home.sessionVariables.HOMEBREW_BUNDLE_FILE = "${config.xdg.configHome}/homebrew/Brewfile";
    home.packages = [ brewSync ];

    home.activation.brewBundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if ${lib.boolToString cfg.sync.enable}; then
        if ! $DRY_RUN_CMD ${brewSync}/bin/brew-sync; then
          ${if cfg.sync.strict then "exit 1" else ''echo "warning: Homebrew bundle synchronization failed" >&2''}
        fi
      fi
    '';
  };
}

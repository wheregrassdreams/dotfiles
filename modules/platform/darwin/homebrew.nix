{ config, lib, pkgs, userName, inputs, ... }:
let
  cfg = config.dotfiles.platform.darwin.homebrew;
  activation = cfg.onActivation;
  brewSync = pkgs.writeShellScriptBin "brew-sync" ''
    set -u

    brew=${lib.escapeShellArg "${config.homebrew.brewPrefix}/brew"}
    brewfile=${lib.escapeShellArg config.environment.variables.HOMEBREW_BUNDLE_FILE}

    if [ ! -x "$brew" ]; then
      echo "Homebrew is not installed; skipping sync." >&2
      exit 0
    fi

    export PATH="${config.homebrew.brewPrefix}:${lib.makeBinPath [ pkgs.mas ]}:$PATH"

    needs_sync() {
      if ! "$brew" bundle check --file="$brewfile" --no-upgrade; then
        return 0
      fi

      ${lib.optionalString (!activation.keepUndeclared) ''
        if ! "$brew" bundle cleanup --file="$brewfile" --zap >/dev/null 2>&1; then
          return 0
        fi
      ''}

      return 1
    }

    case "''${1:-}" in
      "")
        if ! needs_sync; then
          echo "Homebrew bundle already satisfies the declared Brewfile."
          exit 0
        fi
        ;;
      --always)
        ;;
      --refresh)
        "$brew" update
        ;;
      *)
        echo "Usage: brew-sync [--refresh]" >&2
        exit 2
        ;;
    esac

    exec ${config.homebrew.onActivation.brewBundleCmd}
  '';
  activationCommand = if activation.mode == "always" then "--always" else "";
  runActivation = ''
    if ! sudo --user=${lib.escapeShellArg userName} --set-home ${brewSync}/bin/brew-sync ${activationCommand}; then
      ${if activation.abortOnFailure then "exit 1" else ''echo "warning: Homebrew bundle failed; continuing activation." >&2''}
    fi
  '';
in {
  options.dotfiles.platform.darwin.homebrew = {
    onActivation = {
      mode = lib.mkOption {
        type = lib.types.enum [ "disabled" "if-needed" "always" ];
        default = "if-needed";
        description = "when Darwin activation synchronizes the declared Homebrew bundle";
      };
      autoUpdate = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "allow Homebrew to update itself when a bundle synchronization runs";
      };
      upgrade = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "upgrade declared Homebrew packages when a bundle synchronization runs";
      };
      keepUndeclared = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "keep Homebrew packages that are absent from the generated Brewfile";
      };
      abortOnFailure = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "fail Darwin activation when Homebrew synchronization fails";
      };
    };
  };
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];
  config = {
  nix-homebrew = {
    enable = true;
    user = userName;
    enableRosetta = false;
    mutableTaps = true;
    taps = {};
  };
  environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
  environment.systemPackages = [ brewSync ];
  homebrew = {
    enable = true;
    global.brewfile = true;
    onActivation = {
      inherit (activation) autoUpdate upgrade;
      cleanup = if activation.keepUndeclared then "none" else "zap";
    };
  };
  system.activationScripts.homebrew.text = lib.mkForce (
    lib.optionalString (activation.mode != "disabled") runActivation
  );
  };
}

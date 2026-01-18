{
  lib,
  pkgs,
  config,
  hostName,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  userName = config.home.username;
in
{
  home.file = {
    ".config/zsh/edit-command-line.zsh".source = ./edit-command-line.zsh;
    ".config/zsh/keybinds.zsh".source = ./keybinds.zsh;
  };

  programs = {
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
      autosuggestion.enable = false; # 使用fzf-tab
      syntaxHighlighting.enable = true;
      autocd = true;

      initContent = lib.mkMerge [
        (lib.mkOrder 550 ''
          mkdir -p ${config.xdg.configHome}/zsh/completions
          fpath+=(${config.xdg.configHome}/zsh/completions)
        '')
        ''
          for file in ${config.xdg.configHome}/zsh/*.zsh; do
            [ -r "$file" ] && source "$file"
          done

          # # 允许中间匹配（substring / fuzzy）
          # zstyle ':completion:*' matcher-list \
          #   'm:{a-zA-Z}={A-Za-z}' \
          #   'r:|[._-]=** r:|=**'
          # zstyle ':completion:*' insert-unambiguous false
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' sort false
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:*' fzf-flags --no-sort
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
          bindkey '^o' custom_edit_command_line

        ''
      ];
      envExtra = ''
        # if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        #   source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        # fi
        # Custom ~/.zshenv goes here
      '';
      profileExtra = ''
        # Custom ~/.zprofile goes here
      '';
      loginExtra = ''
        # Custom ~/.zlogin goes here
      '';
      logoutExtra = ''
        # Custom ~/.zlogout goes here
      '';

      dirHashes = {
        docs  = "${config.home.homeDirectory}/Documents";
        dl    = "${config.home.homeDirectory}/Downloads";
      };

      history = {
        size = 50000;
        save = 50000;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        ignoreSpace = true;
        ignoreDups = true;
        share = true;
        extended = true;
      };

      plugins = [
        {
          name = "zsh-fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
        {
          name = "zsh-completions";
          src = pkgs.zsh-completions;
        }
        {
          name = "zsh-system-clipboard";
          src = pkgs.zsh-system-clipboard;
          file = "share/zsh/zsh-system-clipboard/zsh-system-clipboard.zsh";
        }
      ];

      siteFunctions = {
        mkcd = '' mkdir --parents "$1" && cd "$1" '';
        uuid = '' uuidgen | tr -d '\n' '';
        to_timestamp = '' date '+%s' ''${1:+--date "$1"} '';
        from_timestamp = '' date '+%Y-%m-%d %H:%M:%S' --date @"''${1:0:10}" '';
        timestamp = '' date '+%s' '';
        random = "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1";
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    carapace = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        username = {
          style_user = "blue bold";
          style_root = "red bold";
          format = "[$user]($style)";
          disabled = false;
          show_always = true;
        };
        hostname = {
          ssh_only = false;
          ssh_symbol = "🌐 ";
          format = "@[$hostname](bold red) ";
          trim_at = ".local";
          disabled = false;
        };
      };
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DOTFILES = "$HOME/.dotfiles";
  };

  home.shellAliases = {
    rebuild =
      if isDarwin then
        "sudo darwin-rebuild switch --flake $DOTFILES#${hostName}"
      else
        "sudo nixos-rebuild switch --flake $DOTFILES#${hostName}";
    hm = "nix run home-manager -- switch --flake $DOTFILES#${userName}";
    hm-build = "nix run home-manager -- build --flake $DOTFILES#${userName}";
    # rebuild-fast = "nix-fast-build --flake $DOTFILES#darwinConfigurations.${hostName}";
    update-homebrew = "nix flake update nix-homebrew homebrew-core homebrew-cask --flake $DOTFILES";
    update-nix = "nix flake update nixpkgs nixpkgs-unstable nix-darwin home-manager --flake $DOTFILES";
    clean = "nix-collect-garbage -d && sudo nix-collect-garbage -d && nix store optimise";
    reload = "source ${config.xdg.configHome}/zsh/.zshrc";

    # ls = "eza --color=auto --git --icons=auto --no-user --time-style long-iso";
    ls = "eza";
    cat = "bat";
    top = "btop";
    grep = "rg";
    del = "trash";
    e = "$EDITOR";
    o = "open";
    reveal = "open -R ";
    npm = "pnpm";
    man = "tldr";
    neofetch = "fastfetch";
    ps = "procs";
    http = "xh";
    https = "xh --https";
    du = "dust";

    cb = "NO_COLOR=1 CLIPBOARD_SLIENT=1 cb ";
    cbcopy = "cb copy";
    cbpaste = "cb paste";

    postmock = "http POST https://httpbin.org/post"; 

    server = "python3 -m http.server";
    noansi = ''sed -r "s/\x1B\[[0-9;]*[mK]//g"'';

    codex = "codex --sandbox danger-full-access";

    csv = "csvlens";
    py = "python3";
    python = "python3";
    today = "date +%Y-%m-%d";

    json2string = "jq tostring";

    ".." = "cd ..";
    "..." = "cd ../..";
    "-" = "cd -";

  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}

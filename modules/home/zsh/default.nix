{ pkgs, config, isDarwin, hostName, userName, ... }:
{
  home.file = {
    ".config/zsh/fzf.zsh".source = ./fzf.zsh;
    ".config/zsh/edit-command-line.zsh".source = ./edit-command-line.zsh;
    ".config/zsh/functions.zsh".source = ./functions.zsh;
    ".config/zsh/keybinds.zsh".source = ./keybinds.zsh;
  };

  programs = {
    zsh = {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      envExtra = ''
        # Custom ~/.zshenv goes here
      '';
      initContent = ''
        for file in ${config.xdg.configHome}/zsh/*.zsh; do
          [ -r "$file" ] && source "$file"
        done

        mkdir -p ${config.xdg.configHome}/zsh/completions
        fpath+=(${config.xdg.configHome}/zsh/completions)

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
        bindkey '^o' custom_edit_command_line
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

      history = {
        size = 10000;
        save = 10000;
        path = "$HOME/.zsh_history";
        ignoreSpace = true;
        ignoreDups = true;
        share = true;
        extended = true;
      };

      sessionVariables = {
        EDITOR = "nvim";
        DOTFILES = "$HOME/.dotfiles";
        XDG_CONFIG_HOME = "$HOME/.config";
        EZA_CONFIG_DIR = "$HOME/.config/eza";
      };


      plugins = [
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.zsh-syntax-highlighting;
          file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        }
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
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ "--cmd cd" ];
    };

    starship = {
      enable = true;
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

  home.shellAliases = {
    rebuild = if isDarwin then
      "sudo darwin-rebuild switch --flake $DOTFILES#${hostName}"
    else
      "sudo nixos-rebuild switch --flake $DOTFILES#${hostName}";
    hm = "nix run home-manager -- switch --flake $DOTFILES#${userName}";
    update-homebrew = "nix flake update nix-homebrew homebrew-core homebrew-cask --flake $DOTFILES";
    update-nix = "nix flake update nixpkgs nixpkgs-unstable nix-darwin home-manager --flake $DOTFILES";
    clean = "nix-collect-garbage -d && sudo nix-collect-garbage -d && nix store optimise";
    reload = "source $HOME/.config/zsh/.zshrc";

    ls = "eza --color=auto --git --icons=auto --no-user";
    cat = "bat";
    top = "btop";
        grep = "rg";
        del = "trash";
    e = "$EDITOR";
    npm = "pnpm";
    man = "tldr";
    neofetch = "fastfetch";
    ps = "procs";
    http = "xh";
    https = "xh --https";
    du = "dust";
    codex = "codex --sandbox danger-full-access";

    csv = "csvlens";
    py = "python3";
    python = "python3";
    today = "date +%Y-%m-%d";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
    "......" = "cd ../../../../..";
    "-" = "cd -";

  };


  home.sessionPath = [
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
  ];
}

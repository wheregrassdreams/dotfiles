{ pkgs, config, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session' 
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      tmuxPlugins.dotbar
      tmuxPlugins.vim-tmux-navigator
    ];
    historyLimit = 10000;
    keyMode = "vi";
    mouse = true;
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    escapeTime = 10;

    extraConfig = ''
      bind ',' run-shell 'tmux source-file ${config.xdg.configHome}/tmux/tmux.conf \; display-message -d 800  " #[fg=white] config reloaded"'

      # Yazi 
      set -g allow-passthrough on
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM

      # automatically renumber windows
      set -g renumber-windows on

      set -g set-clipboard on

      set -g focus-events on              # 让 tmux 在焦点变化时触发 hook

      # update the env when attaching to an existing session
      set -g update-environment -r


      # Select pane
      bind h select-pane -L
      bind j select-pane -D 
      bind k select-pane -U
      bind l select-pane -R

      # Split
      bind '|' split-window -h -c "#{pane_current_path}"
      bind '\' split-window -v -c "#{pane_current_path}"

      # Rename window/session
      bind r command-prompt -I "#W" "rename-window '%%'"
      bind R command-prompt -I "#S" "rename-session '%%'"

      # New window/session
      bind n new-window
      bind N new-session

      # Layout
      bind C-l select-layout -o                 # 在最近布局间切换
      bind = select-layout even-horizontal      # 等分水平
      bind + select-layout even-vertical        # 等分垂直
      bind ] select-layout tiled                # 平铺

      # Join pane
      bind @ choose-tree   "join-pane -h -s '%%'"    # prefix + @

      # Close
      bind x kill-pane
      bind X kill-window
      bind q kill-pane
      bind Q kill-window

      # Full
      bind Space resize-pane -Z

      # Resizing
      # 持续按住可连发
      bind -r Up    resize-pane -U 3
      bind -r Down  resize-pane -D 3
      bind -r Left  resize-pane -L 3
      bind -r Right resize-pane -R 3

      # VI style
      setw -g mode-keys vi               # 复制模式按键改成 vi 风格
      # bind '[' copy-mode
      bind -T copy-mode-vi v      send -X begin-selection
      # bind -T copy-mode-vi y      send -X copy-selection-and-cancel
      bind -T copy-mode-vi y      send -X copy-selection
      bind -T copy-mode-vi y      send -X copy-pipe "pbcopy"
      bind -T copy-mode-vi V      send -X select-line
      bind -T copy-mode-vi C-v    send -X rectangle-toggle   # 可选：矩形选择
      bind -T copy-mode-vi q      send -X cancel
      bind -T copy-mode-vi Escape if-shell -F '#{selection_active}' \
        'send -X clear-selection' \
        'send -X cancel'
      bind -T copy-mode-vi C-[ if-shell -F '#{selection_active}' \
        'send -X clear-selection' \
        'send -X cancel'
      bind -T copy-mode-vi / command-prompt -i -p "Search down" "send -X search-forward-incremental \"%%%\""
      bind -T copy-mode-vi ? command-prompt -i -p "Search up" "send -X search-backward-incremental \"%%%\""
      bind -T copy-mode-vi n      send -X search-again
      bind -T copy-mode-vi N      send -X search-reverse

      bind f display-popup -B -w 60% -h 50% -E "tmux list-windows -a -F '#{session_name}:#{window_index}:#{window_name}' | fzf --gutter=' ' --scrollbar='▌ ' --border --height 100% --reverse --prompt='>' --info hidden | cut -d: -f1,2 | xargs -I {} tmux switch-client -t {}"

      # Toggle status bar visibility
      # https://dev.to/rahuldhole/tmux-toggle-status-bar-288m
      bind b run-shell "tmux setw -g status \$(tmux show -g -w status | grep -q off && echo on || echo off)"


    '';

  };

  home.file = {
    # ".config/tmux/plugins".source = ./tmux/plugins;
    ".config/tmux/scripts".source = ./tmux/scripts;
  };
}

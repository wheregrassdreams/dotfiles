{ config, lib, ... }: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
    defaultOptions = [
      "--ansi" "--multi"
      "--bind 'ctrl-/:toggle-preview'"
      "--bind 'ctrl-u:preview-half-page-up'"
      "--bind 'ctrl-d:preview-half-page-down'"
      "--preview-window=right:50%:hidden"
      "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | rg -q \"image/\"; then timg -g \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"
      "--layout=reverse" "--height 60%"
      "--color=fg:#d0d0d0,fg+:#d0d0d0,bg:-1,bg+:#262626"
      "--color=hl:#6546ff,hl+:#ff9adf,info:#676767,marker:#6546ff"
      "--color=prompt:#676767,spinner:#6546ff,pointer:#6546ff,header:#434343"
      "--color=border:#262626,label:#676767,query:#d9d9d9,scrollbar:#676767"
      "--separator='─' --scrollbar='▌' --layout='reverse' --info='right'"
      "--preview-window='border-sharp' --prompt='' --marker='▎ ' --pointer='' "
    ];
    fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .DS_Store";
    fileWidgetOptions = [
      "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; elif file --mime-type {} | rg -q \"image/\"; then timg -g \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} {}; else bat -n --color=always --line-range :500 {}; fi'"
    ];
    historyWidgetOptions = [ "--sort" "--exact" "--preview 'echo {}'" "--preview-window=down:3:hidden" "--bind 'ctrl-/:toggle-preview'" ];
  };

  home.file.".config/shell/fzf-header.sh".source = ./fzf-header.sh;
  programs.zsh.initContent = lib.mkAfter ''source ${config.xdg.configHome}/shell/fzf-header.sh'';
}

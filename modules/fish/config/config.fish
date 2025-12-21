if status is-interactive
    # Commands to run in interactive sessions can go here



    function fish_user_key_bindings
        fish_vi_key_bindings
    end

    set -g fish_vi_force_cursor 1

    function fish_mode_prompt
        # echo -n "$fish_bind_mode "
    end


    # set fish_cursor_default block blink
    set fish_cursor_insert line
    set fish_cursor_replace_one underscore blink
    set fish_cursor_visual block

end


# PATH stuff
export GOPATH=$HOME/Documents/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:$GOPATH/bin:$GOROOT/bin"
export PATH="/opt/X11/bin:$PATH"
export PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"
export PATH="$PATH:$HOME/.local/bin"

# Alias
# CLI Alternative
# alias man='tldr -t base16'
alias man='tldr'
alias vim='nvim '
alias ls='eza --color=always --git --icons=always --no-user'
alias cat='bat '
alias y='yazi '
alias py='python '
# alias ls='eza --color=always --long --git --icons=always --no-user'
# alias cd='z '

export MYBLOG_DIR="$HOME/Documents/myblog/"
alias blog="cd $MYBLOG_DIR"
alias blog_publish="cd $MYBLOG_DIR && hugo && rsync -vau -e 'ssh -p 22000' --delete ~/Documents/myblog/public/ zach@ssh.thecheatcode.site:~/Services/nginx/nginx/html/myblog "
alias bp='blog_publish'

alias nvd='neovide --frame buttonless --title-hidden'
alias e='$EDITOR'
alias sudo='sudo -E '
alias ze='zellij attach'

export FZF_DEFAULT_COMMAND="fd . $HOME"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" # CTRL-T to fuzzily search for a file or directory in your home directory then insert its path at the cursor 
export FZF_ALT_T_COMMAND="fd -t d . $HOME" # ALT-C to fuzzily search for a directory in your home directory then cd into it
fzf --fish | source

# starship init fish | source

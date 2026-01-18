tmux list-windows -a -F $'#{?session_attached,1,0}#{?window_active,1,0}#{session_last_attached}\t#{session_name}:#{window_index}\t\e[38;5;245m#{session_name}\e[0m\t\e[38;2;222;222;222m#{window_name}\e[0m' |
    sort -rnk1 $1 |
    fzf --tmux --ansi --delimiter=$'\t' --with-nth=3,4  --tabstop=12 --preview 'tmux capture-pane -ep -S -200 -E 1 -t {2}' --preview-window +190 |
    cut -f 2 | xargs -I {} tmux switch-client -t {}

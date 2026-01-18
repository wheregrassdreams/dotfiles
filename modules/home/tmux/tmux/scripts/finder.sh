SOURCE_CMD="$(cat <<'EOF'
tmux list-windows -a -F $'#{?session_attached,1,0}#{?window_active,1,0}#{session_last_attached}\t#{session_name}\t#{session_name}:#{window_index}\t\e[38;5;245m#{session_name}\e[0m\t\e[38;2;222;222;222m#{window_name}\e[0m' |
sort -rnk1
EOF
)"

# echo $SOURCE_CMD
sh -c "$SOURCE_CMD"  |
fzf --tmux --ansi \
    --delimiter=$'\t' \
    --with-nth=4,5 \
    --tabstop=12 \
    --preview 'tmux capture-pane -ep -S -200 -E 1 -t {3}' \
    --preview-window +190 \
    --bind 'ctrl-x:execute-silent(printf "%s\n" {+2} | xargs -r -n1 tmux kill-session -t)+reload:'"$SOURCE_CMD" |
cut -f 3 |
xargs -I {} tmux switch-client -t {}

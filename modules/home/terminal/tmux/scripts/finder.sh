SOURCE_CMD="$(cat <<'EOF'
tmux list-windows -a -F $'#{?session_attached,1,0}#{?window_active,1,0}#{session_last_attached}\t#{session_name}\t#{session_name}:#{window_index}\t\e[38;5;245m#{session_name}\e[0m\t\e[38;2;222;222;222m#{window_name}\e[0m\t\e[38;2;103;103;103m#{?session_attached,#{?window_active,(current),},} #{?window_last_flag,,}\e[0m' |
sort -rnk1
EOF
)"

fzf_header() {
  local color1='\033[38;2;103;103;103m'
  local reset='\033[0m'
  echo "${color1}enter${reset} switch to   ${color1}^x${reset} kill    ${color1}^/${reset} preview    ${color1}tab${reset} multi"
}

sh -c "$SOURCE_CMD" |
  fzf --tmux --ansi \
    --delimiter=$'\t' \
    --with-nth=4,5,6 \
    --tabstop=12 \
    --prompt=' ' \
    --preview 'tmux capture-pane -ep -S -200 -E 1 -t {3}' \
    --preview-window +190 \
    --header "$(fzf_header)" \
    --bind 'ctrl-x:execute-silent(printf "%s\n" {+3} | xargs -r -n1 tmux kill-window -t)+reload:'"$SOURCE_CMD" |
  cut -f 3 |
  xargs -I {} tmux switch-client -t {}

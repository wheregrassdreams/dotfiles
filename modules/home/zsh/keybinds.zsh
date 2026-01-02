# ============================================================================
# VI Mode
# ============================================================================

bindkey -v   # enable vi mode
KEYTIMEOUT=1 # Reduce mode switching delay
# Change cursor shape based on VI mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'   # Block cursor
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'   # Beam cursor
  fi
}
zle -N zle-keymap-select #

# Use beam cursor for each new prompt
_fix_cursor() { echo -ne '\e[5 q' }
precmd_functions+=(_fix_cursor)


bindkey -a "j" .down-line
bindkey -a "k" .up-line

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# 修复 vi 模式下 Backspace 失效的问题
bindkey "^?" backward-delete-char     # 终端常用 Backspace
bindkey "^H" backward-delete-char      # 有些终端发送 ^H

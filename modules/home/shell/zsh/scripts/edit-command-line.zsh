# ============================================================================
# Functions
# ============================================================================


autoload -U edit-command-line
zle -N edit-command-line

function custom_edit_command_line() {
  if [[ -n "$TMUX" ]]; then
    tmux_edit_command_line
  else
    zle edit-command-line
  fi
  echo -ne '\e[5 q'
}

function tmux_edit_command_line() {
  local tmpfile=$(mktemp /tmp/zshcmd.XXXXXX)
  print -r -- "$BUFFER" > "$tmpfile"

  # 当前 pane 尺寸
  local pane_width=$(tmux display -p -F "#{pane_width}")
  local pane_height=$(tmux display -p -F "#{pane_height}")
  local pane_top=$(tmux display -p -F "#{pane_top}")
  local pane_left=$(tmux display -p -F "#{pane_left}")

  # 当前光标在 pane 内的行号（从 0 开始）
  local cursor_y=$(tmux display -p -F "#{cursor_y}")

  # popup 尺寸（pane 的百分比）
  local popup_width=$(( pane_width ))
  local popup_height=$(( pane_height * 30 / 100 ))
  local min_popup_height=10

  if (( popup_height < min_popup_height )); then
    popup_height=$min_popup_height
  fi

  local space_below=$(( pane_height - cursor_y ))

  direction="down"
  if (( space_below < popup_height + 2 )); then
    direction="up"
  fi

  # 计算 popup 坐标：贴近当前 prompt 上方
  local popup_x=$pane_left
  local popup_y
  if [[ $direction == "down" ]]; then
    popup_y=$(( pane_top + cursor_y + popup_height + 1 ))
  else
    popup_y=$(( pane_top + cursor_y - 1 ))
  fi

  # 确保 popup 不越界
  (( popup_y < pane_top )) && popup_y=$pane_top

  # 打开 popup，标题为当前命令模式
  tmux popup -E -T "Edit Command" \
    -w ${popup_width} -h ${popup_height} \
    -x ${popup_x} -y ${popup_y} \
    "nvim  \
      -c 'setlocal nonumber norelativenumber signcolumn=no laststatus=0 noruler noshowmode noshowcmd' \
      -c 'set cmdheight=0' \
      -c 'set noautowriteall' \
      -c 'set noautowrite' \
      -c 'set noautoread' \
      -c 'autocmd VimEnter * lua vim.cmd(\"normal! GA\"); vim.wo.wrap = true' \
      -c 'set statuscolumn=' \
      -c 'set showtabline=0' \
      -c 'set tabline=' \
      -c 'setlocal winbar=' \
    '$tmpfile'"

  # 更新命令行内容
  if [[ -f "$tmpfile" ]]; then
    BUFFER=$(<"$tmpfile")
  fi
  rm -f "$tmpfile"

  CURSOR=${#BUFFER}

  # 刷新 zle 状态
  zle reset-prompt
  zle redisplay
  zle -I
  zle end-of-line
}

zle -N custom_edit_command_line
bindkey '^o' custom_edit_command_line

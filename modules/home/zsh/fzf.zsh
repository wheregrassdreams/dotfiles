export FZF_COMPLETION_TRIGGER='?'

export FZF_DEFAULT_OPTS="
--layout=reverse --height 45%
--bind '?:toggle-preview'
--bind 'ctrl-/:toggle-preview'
--bind 'ctrl-u:preview-half-page-up'
--bind 'ctrl-d:preview-half-page-down'
--scrollbar='▌ '
--header='Ctrl-/: Toggle preview | Ctrl-D/U: Scroll preview'
--preview-window=right:50%:hidden
--preview '
if [ -d {} ]; then
    lsd --color=always --tree --depth 2 {}
else
    bat --style=numbers --color=always --line-range=:500 {}
fi
'
"

export FZF_CTRL_R_OPTS="
--sort
--exact
--preview 'echo {}'
--preview-window=down:3:hidden
--bind '?:toggle-preview'
"

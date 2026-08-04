{ }:
{
  prefix = [
    { key = "h"; command = "select-pane -L"; }
    { key = "j"; command = "select-pane -D"; }
    { key = "k"; command = "select-pane -U"; }
    { key = "l"; command = "select-pane -R"; }
    { key = "|"; command = ''split-window -h -c "#{pane_current_path}"''; }
    { key = ''\\''; command = ''split-window -v -c "#{pane_current_path}"''; }
    { key = "r"; command = ''command-prompt -I "#W" "rename-window '%%'"''; }
    { key = "R"; command = ''command-prompt -I "#S" "rename-session '%%'"''; }
    { key = "n"; command = "new-window"; }
    { key = "N"; command = "new-session"; }
    { key = "C-l"; command = "select-layout -o"; }
    { key = "="; command = "select-layout even-horizontal"; }
    { key = "+"; command = "select-layout even-vertical"; }
    { key = "]"; command = "select-layout tiled"; }
    { key = "@"; command = ''choose-tree "join-pane -h -s '%%'"''; }
    { key = "x"; command = "kill-pane"; }
    { key = "X"; command = "kill-window"; }
    { key = "q"; command = "kill-pane"; }
    { key = "Q"; command = "kill-window"; }
    { key = "Space"; command = "resize-pane -Z"; }
    { key = "Up"; command = "resize-pane -U 3"; repeat = true; }
    { key = "Down"; command = "resize-pane -D 3"; repeat = true; }
    { key = "Left"; command = "resize-pane -L 3"; repeat = true; }
    { key = "Right"; command = "resize-pane -R 3"; repeat = true; }
  ];

  copyMode = [
    { key = "v"; command = "send -X begin-selection"; }
    { key = "V"; command = "send -X select-line"; }
    { key = "C-v"; command = "send -X rectangle-toggle"; }
    { key = "q"; command = "send -X cancel"; }
    { key = "Escape"; command = "if-shell -F '#{selection_active}' 'send -X clear-selection' 'send -X cancel'"; }
    { key = "C-["; command = "if-shell -F '#{selection_active}' 'send -X clear-selection' 'send -X cancel'"; }
    { key = "/"; command = ''command-prompt -i -p "Search down" "send -X search-forward-incremental \\\"%%%\\\""''; }
    { key = "?"; command = ''command-prompt -i -p "Search up" "send -X search-backward-incremental \\\"%%%\\\""''; }
    { key = "n"; command = "send -X search-again"; }
    { key = "N"; command = "send -X search-reverse"; }
  ];
}

#!/bin/sh
# teammate-mover.sh — move Claude Code agent-team panes out of the lead's window.
#
# Workaround for anthropics/claude-code#23615: with teammateMode "tmux" and the
# lead inside tmux, every teammate is split into the lead's own window. Run from
# tmux's after-split-window hook (see tmux.conf) with the new pane's id and
# the server's socket path.
#
# Claude splits the pane first and only then sends the `claude … --agent-id …`
# command, so this polls the pane's processes for up to ~10s. A split that never
# runs an --agent-id process (the user's own splits) is left alone. Moving is by
# pane id, which Claude keeps tracking (observed 2026-11-17: moved teammates kept
# working and stayed addressable).
#
# Target window: tmux user option @teammate_window (default "agents"); set it to
# "" to disable. Layout: @teammate_layout (default "tiled").
pane=${1:?pane id}
# Always address the server that fired the hook: pane ids are per server, so a bare
# `tmux` (default socket) could act on some other server's %N.
sock=${2:?socket path}
tmux() { command tmux -S "$sock" "$@"; }
win=$(tmux show -gqv @teammate_window)   # set in tmux.conf; empty disables
[ -z "$win" ] && exit 0
layout=$(tmux show -gqv @teammate_layout)
[ -z "$layout" ] && layout=tiled

i=0
while :; do
  tty=$(tmux display -p -t "$pane" '#{pane_tty}' 2>/dev/null) || exit 0   # pane gone
  ps -o args= -t "${tty#/dev/}" 2>/dev/null | grep -q -- '--agent-id' && break
  i=$((i + 1)); [ "$i" -ge 40 ] && exit 0                                   # not a teammate
  sleep 0.25
done

sess=$(tmux display -p -t "$pane" '#{session_id}')
if [ "$(tmux display -p -t "$pane" '#{window_name}')" = "$win" ]; then
  tmux select-layout -t "$pane" "$layout"
  exit 0
fi
if tmux list-windows -t "$sess" -F '#{window_name}' | grep -qxF "$win"; then
  target=$(tmux list-windows -t "$sess" -F '#{window_id} #{window_name}' | awk -v w="$win" '$2 == w {print $1; exit}')
  tmux join-pane -d -s "$pane" -t "$target"
else
  tmux break-pane -d -s "$pane" -t "$sess:" -n "$win"
fi
tmux select-layout -t "$pane" "$layout"

#!/usr/bin/env sh
# Bootstrap the persistent "main" tmux session (idempotent).
#
# - If "main" already exists, do nothing.
# - If no tmux server is running, start it (loads ~/.config/tmux/tmux.conf, which lets
#   tmux-continuum auto-restore on server start), then wait briefly for any
#   restore to recreate "main" from the last save snapshot.
# - If after that "main" still does not exist, create it fresh with 4 windows:
#     1 Primary       2 WorkAgent       3 PersonalAgent       4 Btop+Caffeinate
# - Window 4 splits horizontally: left pane runs `btop`, right pane runs
#   `caffeinate -d` (prevents display sleep, runs in foreground).

# Already exists -> nothing to do.
if tmux has-session -t main 2>/dev/null; then
    exit 0
fi

# `tmux ls` fails with "no server running" when there is no server.
if ! tmux ls >/dev/null 2>&1; then
    tmux start-server
    # Give tmux-continuum a moment to auto-restore "main" from the last
    # save snapshot, if one exists.
    sleep 2
fi

# Check again after potential restore.
if tmux has-session -t main 2>/dev/null; then
    exit 0
fi

# Create the "main" session fresh with 4 named windows.
# (pane-base-index is 1 via ~/.config/tmux/tmux.conf, so panes start at index 1.)
tmux new-session  -d  -s main -n Primary
tmux new-window        -t main: -n WorkAgent
tmux new-window        -t main: -n PersonalAgent
tmux new-window        -t main: -n 'Btop+Caffeinate'

# Split window 4 horizontally: pane 1 (left) + pane 2 (right).
tmux split-window -h -t main:'Btop+Caffeinate'
# pane 1 (left)  -> btop
# pane 2 (right) -> caffeinate -d
tmux send-keys -t main:'Btop+Caffeinate'.1 'btop'          C-m
tmux send-keys -t main:'Btop+Caffeinate'.2 'caffeinate -d' C-m

# Start on the Primary window.
tmux select-window -t main:Primary
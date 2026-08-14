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

# --- TPM self-install (plugins are NOT tracked in git) ---
# Clone TPM if missing, then install any missing plugins. install_plugins is
# idempotent (skips already-installed) and needs tmux installed but not running.
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -f "$TPM_DIR/tpm" ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
"$TPM_DIR/bin/install_plugins" >/dev/null 2>&1 || true

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
tmux send-keys -t main:'Btop+Caffeinate'.1 'btop' C-m
# `caffeinate` is macOS-only; skip the right pane on Linux.
if command -v caffeinate >/dev/null 2>&1; then
    tmux send-keys -t main:'Btop+Caffeinate'.2 'caffeinate -d' C-m
fi

# Start on the Primary window.
tmux select-window -t main:Primary
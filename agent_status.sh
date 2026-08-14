#!/usr/bin/env bash
# Window indicators: robot glyph for claude/opencode/hermes, neovim glyph for nvim.
target="${1:-}"
[ -z "$target" ] && exit 0

# Collect every pid in every pane's process tree.
all=""
for pane_pid in $(tmux list-panes -t "$target" -F '#{pane_pid}' 2>/dev/null); do
  frontier="$pane_pid"
  while [ -n "$frontier" ]; do
    next=""
    for pid in $frontier; do
      all="$all $pid"
      for child in $(pgrep -P "$pid" 2>/dev/null); do
        next="$next $child"
      done
    done
    frontier="$next"
  done
done

[ -n "$all" ] || exit 0
snap=$(ps -o comm=,args= -p $all 2>/dev/null)

printf '%s\n' "$snap" | grep -qiE '(^|[ /])nvim($|[ .])' \
  && printf '#[fg=#9ece6a] \356\232\256'
printf '%s\n' "$snap" | grep -qiE '(^|[ /])(claude|opencode|hermes)($|[ .])' \
  && printf '#[fg=#bb9af7] \363\260\232\251'

#!/usr/bin/env bash
# Caffeinate indicator: yellow powerline block between branch and cwd.
if pgrep -xq caffeinate; then
    printf '#[fg=#bb9af7,bg=#e0af68]\356\202\264#[fg=#16161e,bg=#e0af68,bold] \357\203\264 #[fg=#e0af68,bg=#16161e]\356\202\264'
else
    printf '#[fg=#bb9af7,bg=#16161e]\356\202\264'
fi

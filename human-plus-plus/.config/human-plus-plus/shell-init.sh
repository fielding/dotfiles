#!/bin/zsh
# Portable Human++ shell loader. Generated palette values are mirrored from
# human-plus-plus/dist so interactive shells do not depend on the source repo.

HUMAN_PP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [[ $- == *i* ]]; then
  printf '\e]4;16;rgb:f2/6c/33\e\\'
  printf '\e]4;17;rgb:bb/ff/00\e\\'
  printf '\e]4;18;rgb:28/2b/31\e\\'
  printf '\e]4;19;rgb:3a/3d/42\e\\'
  printf '\e]4;20;rgb:82/80/79\e\\'
  printf '\e]4;21;rgb:db/d6/cc\e\\'
  printf '\e]4;22;rgb:d6/8c/6f\e\\'
  printf '\e]4;23;rgb:d2/fc/91\e\\'
fi

command -v eza >/dev/null && . "$HUMAN_PP_DIR/eza/colors.sh"
command -v fzf >/dev/null && . "$HUMAN_PP_DIR/fzf/colors.sh"

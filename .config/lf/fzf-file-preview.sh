#!/usr/bin/env bash

if [ -d "$1" ]; then
  eza -T -L7 --icons=always --color=always $1
else
  bat -f --paging=never --style=changes $1
fi

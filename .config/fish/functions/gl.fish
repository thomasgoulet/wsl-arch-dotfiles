function gl
    set -f commit (\
    git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" | \
    fzf --ansi --no-sort -m --height 100% --reverse --bind 'tab:down' --bind 'shift-tab:up' \
    --preview 'git show --color=always (echo {} | grep -o "[a-f0-9]\{7\}")' --preview-window=right:61%
    )
    if test "$commit" = ""
        return
    end
    git show --color=always (echo {} | grep -o "[a-f0-9]\{7\}")
end
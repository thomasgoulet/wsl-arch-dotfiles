function fzf-custom
    fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "llt {}"
end

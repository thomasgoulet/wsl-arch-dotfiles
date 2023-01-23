# Open helix inside a directory listed by z chosen via fzf
function hxj
    set -f hx_directory (z -l 2>&1 | sed "s/^[0-9, .]* * //" | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "llt {}")
    if test "$hx_directory" = ""
        return
    end
    helix $hx_directory
    return
end

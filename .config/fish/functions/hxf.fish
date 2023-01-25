# Open helix inside a sub-directory chosen via fzf
function hxf
    set -f hx_directory (fd --type directory -H -E "*.git*" | fzf --height 40% --reverse --inline-info --tiebreak length --bind "tab:down" --bind "shift-tab:up" --preview "llt {}")
    if test "$hx_directory" = ""
        return
    end
    helix $hx_directory
end

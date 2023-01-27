# Open helix inside a sub-directory chosen via fzf
function hxf
    set -f hx_file (rg -n -H . |\
        fzf --height 70% --reverse --inline-info --tiebreak length --bind "tab:down" --bind "shift-tab:up" -d : \
        --preview "bat -n --color=always -r (math max 0, {2}-10): -H {2} {1}" |\
        cut -d : -f 1,2)
    if test "$hx_file" = ""
        return
    end
    helix $hx_file
end

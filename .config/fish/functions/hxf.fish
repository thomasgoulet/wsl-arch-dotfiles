# Open helix inside a sub-directory chosen via fzf
function hxf
    set -f hx_file (rg -n -H . |\
        fzf --inline-info --tiebreak index --preview-window right,60% --bind "tab:up" --bind "shift-tab:down" -d : \
        --preview "bat -n --color=always -r (math max 0, {2}-15): -H {2} {1}" |\
        cut -d : -f 1,2)
    if test "$hx_file" = ""
        return
    end
    helix $hx_file
end

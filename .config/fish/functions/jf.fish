# Jump to a sub-directory via fzf
function jf
    set -f j_directory (fd --type directory -H -E "*.git*" | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "llt {}")
    if test "$j_directory" = ""
        return
    end
    cd $j_directory
end

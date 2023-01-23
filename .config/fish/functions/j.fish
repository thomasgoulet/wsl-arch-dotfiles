# Jump to a common directory with z via fzf
function j
    set -f j_directory (z -l $argv 2>&1 | cut -d " " -f 2- | tr -d " " | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "llt {}")
    if test "$j_directory" = ""
        return
    end
    cd $j_directory
end

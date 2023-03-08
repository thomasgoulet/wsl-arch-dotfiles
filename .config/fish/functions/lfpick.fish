# Output files selected with lf to terminal
function lfpick
    lf -selection-path ~/lf_files.tmp
    if test -e ~/lf_files.tmp
        cat ~/lf_files.tmp
        rm ~/lf_files.tmp
    end
end

# Output files selected with lf to terminal
function lfpick
    zellij run -f -c -- lf -selection-path ~/lf_files.tmp
    set -l lfpid (pgrep -n lf)
    while kill -0 $lfpid 2>/dev/null;
        sleep 0.2;
    end
    if test -e ~/lf_files.tmp
        cat ~/lf_files.tmp
        rm ~/lf_files.tmp
    end
end

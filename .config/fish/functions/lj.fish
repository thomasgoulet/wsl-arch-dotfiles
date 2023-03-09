# Open lf and cd to location when quitting
function lj
    set -l tmp ~/lf_folder.tmp
    lf -last-dir-path=$tmp $argv
    set -l dir (cat $tmp)
    rm -f $tmp
    if test -d $dir
        cd $dir
    end
end

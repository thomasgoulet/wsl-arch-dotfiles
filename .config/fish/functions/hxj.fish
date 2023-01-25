# Open helix inside a directory listed by zoxide
function hxj
    set -f initial_dir (pwd)
    ji
    helix .
    cd $initial_dir
end

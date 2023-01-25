# Open a new zellij tab helix inside a directory listed by zoxide
function hxt
    set -f initial_dir (pwd)
    ji
    set -f destination_dir (pwd)
    cd $initial_dir
    zellij action new-tab -c $destination_dir -n (basename $destination_dir) -l ~/.config/zellij/layouts/edit.kdl
end

# Open helix inside a directory listed by zoxide
function hxj
    set -f initial_dir (pwd)
    ji
    set -f current_dir (pwd)
    if test "$initial_dir" = "$current_dir"
        return
    end
    helix .
    return
end

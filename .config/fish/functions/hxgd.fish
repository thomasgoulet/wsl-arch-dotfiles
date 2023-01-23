# Open helix with all files modified inside the repo (git diff)
function hxgd
    set -f git_directory (git rev-parse --show-toplevel)
    hx (git diff --name-only | sed "s;^;$git_directory/;")
end

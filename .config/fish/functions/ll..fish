# List dir content filtering out everything starting with dots
function ll.
    exa -lah@ -tmodified --no-user --time-style iso --git --ignore-glob=".?*" --icons $argv
end

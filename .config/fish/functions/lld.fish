# List dir content filtering only directories
function lld
    exa -lahD@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons -L2 $argv
end

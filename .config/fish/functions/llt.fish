# List dir content as tree
function llt
    exa -laTh@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons -L2 $argv
end

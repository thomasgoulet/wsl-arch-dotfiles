# List dir content
function ll
    exa -lah@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons $argv
end

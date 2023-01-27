# Install paru packages selected via fzf
function par
    paru -Slq |\
        fzf -q "$1" -m --preview 'paru -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect' |\
        xargs -ro paru -S
end


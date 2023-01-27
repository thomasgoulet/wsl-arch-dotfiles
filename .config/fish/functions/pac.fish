# Install pacman packages selected via fzf
function pac
    pacman -Slq |\
        fzf -q "$1" -m --preview 'pacman -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect' |\
        xargs -ro sudo pacman -S
end

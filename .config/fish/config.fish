if status is-interactive
    # Commands to run in interactive sessions can go here
end

## No greeting
set fish_greeting

## !! shortcuts to last command
function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t $history[1]; commandline -f repaint
        case "*"
            commandline -i !
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind \cr 'commandline -i "$(history | fzf --height 40% --reverse --inline-info --tiebreak length --bind \'tab:down\' --bind \'shift-tab:up\')"'
end

# Macros / Shortcuts

## Git

function gpsup
    set -f fc_git_current_branch (git branch --show-current)
    git push --set-upstream origin $fc_git_current_branch
end

## Helix

function hx
    if test (count $argv) = 0
        set -f hx_directory (z -l 2>&1 | sed "s/^[0-9, .]* * //" | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "exa -lah --no-user --no-permissions --no-time --git --ignore-glob='*.git*' --icons {}")
        if test "$hx_directory" = ""
            return
        end
        helix $hx_directory
        return
    end
    helix $argv
end

function hxd
    if test (count $argv) = 0
        set -f hx_directory (fd --type directory -H -E "*.git*" | fzf --height 40% --reverse --inline-info --tiebreak length --bind "tab:down" --bind "shift-tab:up" --preview "exa -lah --no-user --no-permissions --no-time --git --ignore-glob='*.git*' --icons {}")
        if test "$hx_directory" = ""
            return
        end
        helix $hx_directory
        return
    end
    helix $argv
end

## Jump / Navigation

function j
    set -f j_directory (z -l 2>&1 | sed "s/^[0-9, .]* * //" | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "exa -lah --no-user --no-permissions --no-time --git --ignore-glob='*.git*' --icons {}")
    if test "$j_directory" = ""
        return
    end
    cd $j_directory
end

function jf
    set -f j_directory (fd --type directory -H -E "*.git*" | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "exa -lah --no-user --no-permissions --no-time --git --ignore-glob='*.git*' --icons {}")
    if test "$j_directory" = ""
        return
    end
    cd $j_directory
end

## Package Management

function par
    paru -Slq | fzf -q "$1" -m --preview 'paru -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect' | xargs -ro paru -S
end

function pac
    pacman -Slq | fzf -q "$1" -m --preview 'pacman -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect' | xargs -ro sudo pacman -S
end

## Listing content of directories

function ll
    exa -lah@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons
end

function ll.
    exa -lah@ -tmodified --no-user --time-style iso --git --ignore-glob=".?*" --icons
end

function lld
    exa -lahD@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons -L2
end

function llt
    exa -laTh@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons -L2
end
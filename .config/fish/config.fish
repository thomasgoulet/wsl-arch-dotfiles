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
    helix $argv
end

function hxj
    set -f hx_directory (z -l 2>&1 | sed "s/^[0-9, .]* * //" | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview "exa -lah --no-user --no-permissions --no-time --git --ignore-glob='*.git*' --icons {}")
    if test "$hx_directory" = ""
        return
    end
    helix $hx_directory
    return
end

function hxd
    set -f hx_directory (fd --type directory -H -E "*.git*" | fzf --height 40% --reverse --inline-info --tiebreak length --bind "tab:down" --bind "shift-tab:up" --preview "exa -lah --no-user --no-permissions --no-time --git --ignore-glob='*.git*' --icons {}")
    if test "$hx_directory" = ""
        return
    end
    helix $hx_directory
    return
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

## Kubernetes

kubectl completion fish | source
helm completion fish | source

function kcon
    kubectl config use-context (kubectl config get-contexts | fzf --height 10% --reverse --inline-info --bind 'tab:down' --bind 'shift-tab:up' --delimiter=' ' --nth=2.. --header-lines=1 | cut -c 2- | awk '{print $1}')
end

function azsub
    az account set -s (az account list | jq -r '.[] | [(if .isDefault then "*" else " " end), .name]|@tsv' | fzf --height 10% --reverse --inline-info --bind 'tab:down' --bind 'shift-tab:up' | cut -f 2)
end
## Note taking

function notes
    
    set -f notes_dir "/home/thomas/notes/Journal"
    
    # Open today's note
    if test (count $argv) = 0
          
        set -l todays_date (date +%Y-%m-%d)
              
        if not test -e $notes_dir/$todays_date.md
            echo > $notes_dir/$todays_date.md "\
---
created: $todays_date
updated: $todays_date
---
#journal
# $todays_date
---

  - [ ]
"
        end
        
        notes n journal/(date +%Y-%m-%d)
        return
    end
    
    # Install
    if test "$argv[1]" = "install"
        curl https://raw.githubusercontent.com/pimterry/notes/latest-release/notes > /usr/local/bin/notes && chmod +x /usr/local/bin/notes
        return
    end
    
    # Todos
    if test "$argv[1]" = "todo"
        for s in (rg --line-number --no-heading "\[ \]" $notes_dir | fzf -m --with-nth=3 --delimiter : --preview 'bat --theme OneHalfDark --style="changes,header,numbers" {1} --highlight-line {2} --color=always' --height 40% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect')
            set -l fileinfo (string split ':' "$s")
            sed -i $fileinfo[2]'s/\[ \]/\[x\]/' $fileinfo[1]
        end
        return
    end
    
    # Undo Todos
    
    if test "$argv[1]" = "doto"
        for s in (rg --line-number --no-heading "\[x\]" $notes_dir | fzf -m --with-nth=3 --delimiter : --preview 'bat --theme OneHalfDark --style="changes,header,numbers" {1} --highlight-line {2} --color=always' --height 40% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect')
            set -l fileinfo (string split ':' "$s")
            sed -i $fileinfo[2]'s/\[x\]/\[ \]/' $fileinfo[1]
        end
        return
    end

    
    command notes $argv

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
    exa -lah@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons $argv
end

function ll.
    exa -lah@ -tmodified --no-user --time-style iso --git --ignore-glob=".?*" --icons $argv
end

function lld
    exa -lahD@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons -L2 $argv
end

function llt
    exa -laTh@ -tmodified --no-user --time-style iso --git --ignore-glob="*.git*" --icons -L2 $argv
end
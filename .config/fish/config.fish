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
    bind \cr 'commandline -i "$(history | fzf --height 40% --reverse --inline-info +s --bind \'tab:down\' --bind \'shift-tab:up\')"'
end

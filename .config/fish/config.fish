if status is-interactive
    # Commands to run in interactive sessions can go here
    if not set -q ZELLIJ
        zellij attach -c thomas
    end
end

## No greeting
set fish_greeting

function fish_user_key_bindings
    bind ! bind_bang
    bind \cr 'commandline -i "$(history | fzf --height 40% --reverse --inline-info --tiebreak length --bind \'tab:down\' --bind \'shift-tab:up\')"'
end

zoxide init fish --cmd j | source

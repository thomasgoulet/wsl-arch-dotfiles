module aliases {

    export alias bye = wsl.exe --shutdown
    export alias c = clear
    export alias b64 = decode base64
    export alias expl = explorer.exe .
    export alias f = lf
    export alias k9t =  zellij action new-tab -c ~ -n k9s -l ~/.config/zellij/layouts/k9s.kdl
    export alias l = ls -las
    export alias lg = lazygit
    export alias procs = mprocs -c ~/.config/mprocs/mprocs.yaml
    export alias pshell = powershell.exe -NoExit -Command "Set-Location $env:USERPROFILE"
    export alias rf = zellij run -c -f --
    export alias r = zellij run -c --
    export alias tf = terraform
    export alias tg = terragrunt

    export alias jf = cd (
    dirname (fd -t f | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview 'exa -T -L2 {1}'))

    # Search pacman's packages via fzf and install
    export def pac [] {
        pacman -Slq
        | fzf -m --preview 'pacman -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect'
        | xargs -ro sudo pacman -S;
  }

    # Search AUR's packages via fzf and install
    export def par [] {
        paru -Slq
        | fzf -m --preview 'paru -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect'
        | xargs -ro paru -S;
    }

    # Launch wsl-vpnkit
    export def vpn [] {
        wsl.exe -d wsl-vpnkit service wsl-vpnkit start out> /dev/null err> /dev/null
    }

}

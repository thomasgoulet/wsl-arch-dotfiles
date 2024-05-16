module aliases {

  export alias bye = wsl.exe --shutdown
  export alias c = clear
  export alias decode = base64 -d
  export alias expl = explorer.exe .
  export alias f = lf
  export alias jf = cd (dirname (fd -t f | fzf --height 40% --reverse --inline-info --tiebreak length --bind 'tab:down' --bind 'shift-tab:up' --preview 'exa -T -L2 {1}'))
  export alias k9t =  zellij action new-tab -c ~ -n k9s -l ~/.config/zellij/layouts/k9s.kdl
  export alias lg = lazygit
  export alias pshell = powershell.exe -NoExit -Command "Set-Location $env:USERPROFILE"
  export alias rf = zellij run -c -f --
  export alias r = zellij run -c --
  export alias tf = terraform
  export alias tg = terragrunt
  export alias vpnkit = wsl.exe -d wsl-vpnkit service wsl-vpnkit start

  # List directory content
  export def ll [
    path?:string  # Optional path to list directory for
  ] {
    if $path == null {
      ls -la | select name mode size modified
    } else {
      ls -la $path | select name mode size modified
    }
  }

  # Search pacman's packages via fzf and install
  export def pac [] {
    pacman -Slq |
      fzf -m --preview 'pacman -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect' |
      xargs -ro sudo pacman -S
  }

  # Search AUR's packages via fzf and install
  export def par [] {
    paru -Slq |
     fzf -m --preview 'paru -Si {1}' --height 50% --reverse --bind 'tab:down' --bind 'shift-tab:up' --bind 'space:select' --bind 'ctrl-space:deselect' |
     xargs -ro paru -S
  }

}

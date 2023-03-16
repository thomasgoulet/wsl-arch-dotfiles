module aliases {
  export alias c = clear
  export alias expl = explorer.exe .
  export alias l = lf
  export alias lg = lazygit
  export alias pshell = zellij action new-tab -l ~/.config/zellij/layouts/powershell.kdl
  export alias r = zellij run -c --
  export alias rf = zellij run -c -f --
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

  # List subdirectories contents
  export def llt [
    path?:string  # Optional path to list directory for
  ] {
    mut result = null
    if $path == null {
      $result = (ls -la | where type == dir and name !~ git)
    } else {
      $result = (ls -la $path | where type == dir and name !~ git)
    }

    $result | par-each { |dir| 
      {
        name: $dir.name, 
        subdirs: (
          ls -la $dir.name | where type == dir and name !~ git | select name mode modified
        )
      }
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

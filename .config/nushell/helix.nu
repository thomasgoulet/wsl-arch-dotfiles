module helix {

  # Alias helix to hx
  export alias hx = helix

  # Open files modified with git
  export def hxgd [] {
    let git_root = (git rev-parse --show-toplevel)
    helix (
      git diff --name-only |
      split row "\n" |
      where $it != "" |
      each { |file| $git_root + "/" + $file }
    )
  }

  export def hxf [] {
    let file = (
      rg -n -H . |
      fzf --inline-info --tiebreak index --preview-window right,60% --bind "tab:up" --bind "shift-tab:down" --reverse -d : --preview "bat -n --color=always -r ([0, (({2} | into int) - 15)] | math max) : -H {2} {1}"
    )
    if $file != "" {
      helix ($file | split row ":" | first 2 | reduce {|it, str| $str + ":" + $it })
    }
  }

  # Open folder from zoxide picker
  export def hxj [] {
    let dir = (zoxide query -i)
    if $dir != "" {
      helix $dir
    }
  }

  # Open folder from zoxide picker in a different zellij tab
  export def hxt [] {
    let dir = (zoxide query -i)
    if $dir != "" {
      zellij action new-tab -c $dir -n (basename $dir) -l ~/.config/zellij/layouts/edit.kdl
    }
  }

  export def hx_lfpick [] {
    zellij run -f -c -- lf -selection-path ~/lf_files.tmp
    let lfpid = (pgrep -n lf)

    try {
      while true {
        sleep 0.1sec
        ^kill -0 $lfpid err+out> /dev/null 
      } 
    } catch {
      if ("~/lf_files.tmp" | path exists) {
        print (cat ~/lf_files.tmp)
        rm ~/lf_files.tmp
      }
    }
  }
  
}

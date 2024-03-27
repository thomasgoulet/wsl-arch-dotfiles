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
  export def hxj [
    hint?: string
  ] {
    mut dir = ""
    if $hint != null {
      $dir = (zoxide query $hint)
    } else {
      $dir = (zoxide query -i)
    }
    if $dir != "" {
      helix $dir
    }
  }

  # Open folder from zoxide picker in a different zellij tab
  export def hxt [
    hint?: string
  ] {
    mut dir = ""
    if $hint == "." {
      $dir = $env.PWD
    } else if $hint != null {
      $dir = (zoxide query $hint)
    } else {
      $dir = (zoxide query -i)
    }
    if $dir != "" {
      zellij action new-tab -c $dir -n (basename $dir) -l ~/.config/zellij/layouts/edit.kdl
    }
  }
  
}

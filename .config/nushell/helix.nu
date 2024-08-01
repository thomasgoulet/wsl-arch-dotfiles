module helix {

    # Alias helix to hx
    export alias hx = helix

    # Open folder from zoxide picker in a different zellij tab
    export def prj [
        hint?: string
    ] {
        mut dir = "";
        if ($hint == ".") {
            $dir = $env.PWD;
        } else if ($hint != null) {
            $dir = (zoxide query $hint);
        } else {
            $dir = (zoxide query -i);
        }

        if ($dir != "") {
            zellij action new-tab -c $dir -n (basename $dir) -l ~/.config/zellij/layouts/edit.kdl
        }
    }
  
}

module git {

    # Git alias
    export alias g = git

    # Add all files
    export alias ga = git add .

    # Pull and prune
    export alias gpl = git pull --prune

    # Push
    export alias gps = git push

    def "nu-complete git branches" [] {
        ^git branch
        | lines
        | where $it !~ "HEAD"
        | each {|line|
            $line
            | str replace '[\*\+] ' ''
            | str trim
        };
    }

    def "nu-complete git remote branches" [] {
        ^git branch -a
        | lines
        | where $it !~ "HEAD"
        | where $it !~ \*
        | each {|line|
            $line
            | str replace '[\*\+] ' ''
            | str trim
            | str replace 'remotes/' ''
            | str replace 'origin/' ''
        }
        | uniq;
    }

    # Merge with another branch
    export extern "git merge" [
        branch: string@"nu-complete git branches"  # Branch to checkout
    ]

    # List branches
    export def gb [] {
        git branch -a
        | lines;
    }

    # Delete branches
    export def gbd [
        branch: string@"nu-complete git branches"      # Branch to delete
    ] {
        git branch -D $branch;
    }
  
    # Show git diff
    export alias gd = git diff

    # Show git logs
    export def gl [] {
        let commit = (
            git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"
            | fzf --ansi --no-sort -m --height 100% --reverse --bind 'tab:down' --bind 'shift-tab:up' --preview 'git show --color=always (echo {} | str substring 2..9)' --preview-window=right:61%
        );
        if ($commit != "") {
            git show --color=always ($commit | str substring 2..9);
        }
    }

    # Commit with a message
    export def gm [
        message: string  # Commit message
        --add (-a)  # Add files as well
    ] {
        if $add {
            git commit -am $message;
        } else {
            git commit -m $message;
        }
    }

    # Pull all repos under the current folder recursively
    export def gpla [
        branch = "master"  # Default branch name to use
    ] {
        if (".git" | path exists) {
            print $"Pulling (pwd)";
            git switch $branch o> (null-device);
            git pull --prune o> (null-device);
            return
        }
        ls -a
        | where type == dir
        | par-each {|s|
            cd $s.name;
            gpla;
        }
        return;
    }

    # Show status
    export def gs [] {
        git status --short
        | from ssv -m 1 -n
        | rename STATUS FILE
    }

    # Switch to a new branch
    export def gsc [
        name: string
    ] {
        git switch -c $name;
    }

    # Switch branch
    export def gsw [
        target: string@"nu-complete git remote branches"  # Target to switch to
    ] {
        git switch $target;
    }


}

# Add functionalities to the notes script
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
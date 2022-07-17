function fish_prompt
    if not set -q VIRTUAL_ENV_DISABLE_PROMPT
        set -g VIRTUAL_ENV_DISABLE_PROMPT true
    end
    set_color green
    printf '%s' $USER
    set_color normal
    printf ' in '

    set_color blue
    printf '%s' (pwd | sed 's+/home/thomas+~+g')
    set_color normal

    set -l GIT_BRANCH (git branch --show-current 2>/dev/null)
    if test -n "$GIT_BRANCH"
        printf ' on '
        set_color yellow
        printf '%s' $GIT_BRANCH
        set_color normal
    end

    # Line 2
    echo
    if test -n "$VIRTUAL_ENV"
        printf "(%s) " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
    end
    printf '↪ '
    set_color normal
end

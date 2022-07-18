function fish_prompt

    set -l promptstatus $status

    if not set -q VIRTUAL_ENV_DISABLE_PROMPT
        set -g VIRTUAL_ENV_DISABLE_PROMPT true
    end

    # User
    set_color green
    printf '%s' $USER
    set_color normal

    # Kubectl Context
    set -l KUBE_CONTEXT (cat ~/.kube/config | grep 'current-context:' | sed 's/current-context: //')
    if test -n "$KUBE_CONTEXT"
        printf ' ['
        set_color purple 
        printf '⎈%s' $KUBE_CONTEXT
        set_color normal
        printf ']'
    end

    printf ' in '

    # Pwd
    set_color blue
    printf '%s ' (pwd | sed 's+/home/thomas+~+g')
    set_color normal

    # Git Branch
    set -l GIT_BRANCH (git branch --show-current 2>/dev/null)
    if test -n "$GIT_BRANCH"
        printf '['
        set_color yellow
        printf '%s' $GIT_BRANCH
        set_color normal
        printf '] '
    end
 
    # Line 2
    echo
    
    if test -n "$VIRTUAL_ENV"
        printf "(%s) " (set_color blue)(basename $VIRTUAL_ENV)(set_color normal)
    end

    if test $promptstatus != '0'
        set_color red
        printf '%s' $promptstatus
        set_color normal
    end
    
    printf ' ↪ '
    set_color normal
end

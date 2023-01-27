# Swtich kubernetes context via fzf
function kcon
    kubectl config use-context (kubectl config get-contexts |\
        fzf --height 10% --reverse --inline-info --bind 'tab:down' --bind 'shift-tab:up' --delimiter=' ' --nth=2.. --header-lines=1 |\
        cut -c 2- |\
        awk '{print $1}')
end

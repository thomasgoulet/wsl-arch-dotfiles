# Switch azure subscription via fzf
function azsub
    az account set -s (az account list |\
        jq -r '.[] | [(if .isDefault then "*" else " " end), .name]|@tsv' |\
        fzf --height 10% --reverse --inline-info --bind 'tab:down' --bind 'shift-tab:up' |\
        cut -f 2)
end

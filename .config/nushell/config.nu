# Nushell Config File

let theme = {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: { || if $in { 'light_cyan' } else { 'light_gray' } }
    int: yellow
    filesize: {|e|
        if ($e == 0b) {
            'white'
        } else if ($e < 1mb) {
            'cyan'
        } else { 'blue' }
    }
    duration: cyan
    date: { || (date now) - $in |
        if $in < 1hr {
            'light_red'
        } else if ($in < 6hr) {
            'light_orange'
        } else if ($in < 1day) {
            'yellow'
        } else if ($in < 3day) {
            'light_green'
        } else if ($in < 1wk) {
            'green'
        } else if ($in < 6wk) {
            'blue'
        } else { 
            'light_gray'
        }
    }    
    range: white
    float: yellow
    string: green
    nothing: white
    binary: white
    cellpath: cyan
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: light_gray

    shape_and: purple_bold
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_blue
    shape_custom: green
    shape_datetime: blue_bold
    shape_directory: blue
    shape_external: blue
    shape_externalarg: green_bold
    shape_filepath: blue
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: red_underline
    shape_globpattern: blue_bold
    shape_int: purple_bold
    shape_internalcall: blue_bold
    shape_list: blue_bold
    shape_literal: blue
    shape_matching_brackets: { attr: u }
    shape_nothing: light_blue
    shape_operator: yellow
    shape_or: purple_bold
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: blue_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: blue_bold
    shape_table: blue_bold
    shape_variable: purple
}

$env.config = {
    ls: {
        use_ls_colors: true
        clickable_links: false
    }

    rm: {
        always_trash: false
    }

    table: {
        mode: rounded
        index_mode: auto
        padding: { left: 1, right: 1 }
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
            truncating_suffix: "..."
        }
        header_on_separator: false
    }

    error_style: "fancy"

    history: {
        max_size: 10000
        sync_on_enter: true
        file_format: "sqlite"
    }

    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: false # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
            max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
            completer: null
        }
        use_ls_colors: true
    }

    filesize: {
        metric: true
        format: "auto"
    }

    cursor_shape: {
        emacs: line
        vi_insert: block
        vi_normal: underscore
    }

    color_config: $theme
    use_grid_icons: true
    footer_mode: "25" # always, never, number_of_rows, auto
    float_precision: 2
    use_ansi_coloring: true
    edit_mode: emacs
    shell_integration: {
        osc2: true
        osc7: true
        osc8: true
        osc9_9: true
        osc133: true
        osc633: true
        reset_application_mode: true
    }

    show_banner: false

    render_right_prompt_on_last_line: false
    use_kitty_protocol: false
    highlight_resolved_externals: false
    recursion_limit: 50

    hooks: {
        display_output: { ||
            if ((term size).columns >= 100) { table -e } else { table }
        }
    }

    menus: [
        {
            name: completion_menu
            only_buffer_difference: false
            marker: ""
            type: {
                layout: columnar
                columns: 4
                col_padding: 2
            }
            style: {
                text: yellow
                selected_text: blue_reverse
                description_text: blue
            }
        }
        {
            name: history_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: list
                page_size: 20
            }
            style: {
                text: yellow
                selected_text: blue_reverse
                description_text: blue
            }
        }
        {
            name: help_menu
            only_buffer_difference: true
            marker: "? "
            type: {
                layout: description
                columns: 4
                col_padding: 2
                selection_rows: 4
                description_rows: 10
            }
            style: {
                text: yellow
                selected_text: blue_reverse
                description_text: blue
            }
        }
        {
            name: vars_menu
            only_buffer_difference: true
            marker: "# "
            type: {
                layout: list
                page_size: 10
            }
            style: {
                text: green
                selected_text: green_reverse
                description_text: yellow
            }
            source: { |buffer, position|
                $nu.scope.vars
                | where name =~ $buffer
                | sort-by name
                | each { |it| {value: $it.name description: $it.type} }
            }
        }
    ]

    keybindings: [
        # Default keybindings
        {
            name: completion_menu
            modifier: none
            keycode: tab
            mode: [emacs vi_normal vi_insert]
            event: {
                until: [
                    { send: menu name: completion_menu }
                    { send: menunext }
                ]
            }
        }
        {
            name: completion_previous
            modifier: shift
            keycode: backtab
            mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
            event: { send: menuprevious }
        }
        {
            name: fuzzy_history
            modifier: control
            keycode: char_h
            mode: [emacs, vi_normal, vi_insert]
            event: [
                {
                    send: ExecuteHostCommand
                    cmd: "commandline edit (
                              history
                              | where exit_status == 0
                              | get command
                              | reverse
                              | uniq
                              | str join (char -i 0)
                              | fzf --read0 --height 40% --reverse --inline-info +s --bind 'tab:down' --bind 'shift-tab:up' -q (commandline)
                              | decode utf-8
                              | str trim
                          )"
                }
            ]
        }
        {
            name: fuzzy_local_history
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: [
                {
                    send: ExecuteHostCommand
                    cmd: "commandline edit (
                              history
                              | where exit_status == 0 and cwd == $env.PWD
                              | get command
                              | reverse
                              | uniq
                              | str join (char -i 0)
                              | fzf --read0 --height 40% --reverse --inline-info +s --bind 'tab:down' --bind 'shift-tab:up' -q (commandline)
                              | decode utf-8
                              | str trim
                          )"
                }
            ]
        }
        {
            name: yank
            modifier: control
            keycode: char_y
            mode: emacs
            event: { until: [ {edit: pastecutbufferafter} ] }
        }
        {
            name: unix-line-discard
            modifier: control
            keycode: char_u
            mode: [emacs, vi_normal, vi_insert]
            event: { until: [ {edit: cutfromlinestart} ] }
        }
        {
            name: kill-line
            modifier: control
            keycode: char_k
            mode: [emacs, vi_normal, vi_insert]
            event: { until: [ {edit: cuttolineend} ]
            }
        }
        # Keybindings used to trigger the user defined menus
        {
            name: vars_menu
            modifier: alt
            keycode: char_o
            mode: [emacs, vi_normal, vi_insert]
            event: { send: menu name: vars_menu }
        }
    ]
}

# Required modules
use std *

source ~/.config/nushell/cache.nu
use cache

# Use zoxide
source ~/.cache/zoxide/init.nu

# Use starship
source ~/.cache/starship/init.nu

# Source aliases
source ~/.config/nushell/aliases.nu
use aliases *

# argo aliases and functions
source ~/.config/nushell/argo.nu
use argo *

# azure-cli aliases and functions
source ~/.config/nushell/az.nu
use az *

# git aliases and completion
source ~/.config/nushell/git.nu
use git *

# helix aliases and functions
source ~/.config/nushell/helix.nu
use helix *

# kubectl aliases and functions
source ~/.config/nushell/kube.nu
use kube *

# Custom completions
module completions {}
use completions *

# Open ZelliJ session if not inside one
if ($env | columns | where $it == ZELLIJ | is-empty) {
    zellij attach -c thomas
}

function resolve-l
    set default 1
    set display_mode default
    set hidden 0
    set recursion_mode none
    set sort_mode type
    set force_grid 0
    set git_ignore 0
    if not test $argv[1] = l
        for char in (string split "" (string sub --start 2 $argv[1]))
            switch $char
                case 0
                    set default 0
                case l
                    set display_mode long
                case 1
                    set display_mode oneline
                case a
                    set hidden 1
                case r
                    set recursion_mode recurse
                case t
                    set recursion_mode tree
                case c
                    set sort_mode created
                case C
                    set sort_mode Created
                case m
                    set sort_mode modified
                case M
                    set sort_mode Modified
                case z
                    set sort_mode size
                case Z
                    set sort_mode Size
                case b
                    set sort_mode name
                case B
                    set sort_mode Name
                case x
                    set sort_mode ext
                case X
                    set sort_mode Ext
                case s
                    set sort_mode accessed
                case S
                    set sort_mode Accessed
                case g
                    set force_grid 1
                case i
                    set git_ignore 1
                case "*"
                    return 1
            end
        end
    end
    set flags
    if test $default = 1
        set -a flags --classify=automatic
    end
    switch $display_mode
        case long
            set -a flags --long
            if test $default = 1
                set -a flags --git
            end
        case oneline
            set -a flags --oneline
    end
    if test $hidden = 1
        set -a flags --all
    end
    switch $recursion_mode
        case recurse
            set -a flags --recurse
        case tree
            set -a flags --tree
    end
    if test $force_grid = 1
        if not test $display_mode = long
            return 1
        end
        set -a flags --grid
    end
    if test $git_ignore = 1
        set -a flags --git-ignore
    end
    set -a flags --sort=$sort_mode
    string join -- " " eza $flags
end

abbr --add eza --regex "l[0l1artcCmMzZBxXsSgi]*" --function resolve-l

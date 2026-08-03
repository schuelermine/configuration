function ffmpeg-hide-banner
    echo $argv[1] -hide_banner $argv[2..]
end

abbr --add ffmpeg --regex "ff(mpeg|play|probe)" --function ffmpeg-hide-banner

function expand-dots
    if not set -q argv[2]
      set argv[2] 0
    end
    set --local length (string length $argv[1])
    set --local additional (math $length - 2 - $argv[2])
    set --local path ..
    for i in (seq $additional)
        set path "$path/.."
    end
    echo $path
end

abbr --add dots --regex '\.{2,}' --function expand-dots

function expand-dots-dollar
    expand-dots $argv[1] 1
end

abbr --add dots-dollar --position anywhere --regex '\$\.{2,}' --function expand-dots-dollar

abbr --add --position=anywhere \$+ --set-cursor="%" "mktemp --suffix=% | tee /dev/stderr"

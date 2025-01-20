function ffmpeg-hide-banner
    echo $argv[1] -hide_banner $argv[2..]
end

abbr --add ffmpeg --regex "ff(mpeg|play|probe)" --function ffmpeg-hide-banner

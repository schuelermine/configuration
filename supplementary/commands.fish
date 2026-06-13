function ret
  cd (command ret $argv)
end

function whence
  namei "$(which $argv[1])"
end

setopt LOCAL_OPTIONS PIPE_FAIL
local zdumpfile zout zopt
zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile="${ZDOTDIR:-${HOME}}/.zcompdump"
[[ ${1} != -q ]] && zopt='-v'
command rm -f ${zopt} ${zdumpfile}{,.zwc{,.old}} || return 1
if [[ ${1} != -q ]]; then
  print -P "%F{green}✓%f Done with ${0:t:r}. Restart your terminal to dump an updated configuration."
fi

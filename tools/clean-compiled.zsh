setopt LOCAL_OPTIONS PIPE_FAIL
local find_opt rm_opt
if [[ ${1} != -q ]]; then
  find_opt='-print'
  rm_opt='-v'
fi
command find ${ZIM_HOME} \( -name '*.zwc' -o -name '*.zwc.old' \) -delete ${find_opt} || return 1
command rm -f ${rm_opt} ${ZDOTDIR:-${HOME}}/.zshrc.zwc{,.old} || return 1
if [[ ${1} != -q ]]; then
  print -P "%F{green}✓%f Done with ${0:t:r}. Run %Bzimfw compile%b to re-compile."
fi

local zdir zmodule
local -a zmodules
local -A zoptions
# Source .zimrc to refresh zmodules
[[ -f ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc
zstyle -a ':zim' modules 'zmodules'
for zdir in ${ZIM_HOME}/modules/*(/N); do
  zmodule=${zdir:t}
  # If zmodules does not contain the zmodule
  if (( ! ${zmodules[(I)${zmodule}]} )); then
    zstyle -a ':zim:module' ${zmodule} 'zoptions'
    [[ ${zoptions[frozen]} == yes ]] && continue
    command rm -rf ${zdir} || return 1
    [[ ${1} != -q ]] && print ${zdir}
  fi
done
if [[ ${1} != -q ]]; then
  print -P "%F{green}✓%f Done with ${0:t:r}."
fi

# Prompt style and colors based on the `steeef` default theme:
# https://github.com/Eriner/zim/blob/master/modules/prompt/themes/steeef.zsh-theme
# Adapted to `Oceanic Next Dark` colors
# Requires the `git-info` zmodule to be included in the .zimrc file.

prompt_naaative_git() {
  [[ -n ${git_info} ]] && print -n " ${(e)git_info[prompt]}"
}

prompt_naaative_virtualenv() {
  [[ -n ${VIRTUAL_ENV} ]] && print -n " (%F{blue}${VIRTUAL_ENV:t}%f)"
}

prompt_naaative_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_naaative_setup() {
  [[ -n ${VIRTUAL_ENV} ]] && export VIRTUAL_ENV_DISABLE_PROMPT=1

  local naaativepink
  local naaativeorange
  local naaativegreen
  local naaativeaqua
  local naaativered
  local naaativeyellow

  naaativepink='%F{magenta}'
  naaativeorange='%F{yellow}'
  naaativegreen='%F{green}'
  naaativeaqua='%F{cyan}'
  naaativered='%F{red}'

  autoload -Uz add-zsh-hook
  autoload -Uz colors && colors

  prompt_opts=(cr percent subst)

  add-zsh-hook precmd prompt_naaative_precmd

  zstyle ':zim:git-info' verbose 'yes'
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:action' format "(${naaativegreen}%s%f)"
  zstyle ':zim:git-info:unindexed' format "${naaativepink}!"
  zstyle ':zim:git-info:indexed' format "${naaativegreen}+"
  zstyle ':zim:git-info:untracked' format "${naaativered}?"
  zstyle ':zim:git-info:stashed' format "${naaativeorange}$"
  zstyle ':zim:git-info:keys' format \
    'prompt' "(${naaativeaqua}%b%c%I%i%u%S%f)%s"

  PROMPT="
${naaativepink}%n%f at ${naaativeorange}%m%f in ${naaativegreen}%~%f\$(prompt_naaative_git)\$(prompt_naaative_virtualenv)
%(!.#.$) "
  RPROMPT=''
}

prompt_naaative_setup "${@}"

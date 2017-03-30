# prompt style and colors based on Steve Losh's Prose theme:
# http://github.com/sjl/oh-my-zsh/blob/master/themes/prose.zsh-theme
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

prompt_steeef_git() {
  [[ -n ${git_info} ]] && print -n " ${(e)git_info[prompt]}"
}

prompt_steeef_virtualenv() {
  [[ -n ${VIRTUAL_ENV} ]] && print -n " (%F{blue}${VIRTUAL_ENV:t}%f)"
}

prompt_steeef_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_steeef_setup() {
  [[ -n ${VIRTUAL_ENV} ]] && export VIRTUAL_ENV_DISABLE_PROMPT=1

  local purple
  local orange
  local limegreen
  local turquoise
  local hotpink
  # use extended color palette if available
  if [[ -n ${terminfo[colors]} && ${terminfo[colors]} -ge 256 ]]; then
    purple='%F{135}'
    orange='%F{166}'
    limegreen='%F{118}'
    turquoise='%F{81}'
    hotpink='%F{161}'
  else
    purple='%F{magenta}'
    orange='%F{yellow}'
    limegreen='%F{green}'
    turquoise='%F{cyan}'
    hotpink='%F{red}'
  fi

  autoload -Uz add-zsh-hook
  autoload -Uz colors && colors

  prompt_opts=(cr percent subst)

  add-zsh-hook precmd prompt_steeef_precmd

  zstyle ':zim:git-info' verbose 'yes'
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:action' format "(${limegreen}%s%f)"
  zstyle ':zim:git-info:unindexed' format "${orange}●"
  zstyle ':zim:git-info:indexed' format "${limegreen}●"
  zstyle ':zim:git-info:untracked' format "${hotpink}●"
  zstyle ':zim:git-info:keys' format \
    'prompt' "(${turquoise}%b%c%I%i%u%f)%s"

  PROMPT="
${purple}%n%f at ${orange}%m%f in ${limegreen}%~%f\$(prompt_steeef_git)\$(prompt_steeef_virtualenv)
%(!.#.$) "
  RPROMPT=''
}

prompt_steeef_setup "$@"

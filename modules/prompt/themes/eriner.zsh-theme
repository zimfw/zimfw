# vim:ts=2 sw=2 sts=2 ft=zsh
#
# Eriner's Theme - fork of agnoster
# A Powerline-inspired theme for ZSH
#
# In order for this theme to render correctly, you will need a font with
# powerline symbols. A simple way to add the powerline symbols is to follow the
# instructions here:
# https://simplyian.com/2014/03/28/using-powerline-symbols-with-your-current-font/
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

### Segment drawing
# Utility functions to make it easy and re-usable to draw segmented prompts.

local prompt_eriner_bg

# Begin a segment. Takes two arguments, background color and contents of the
# new segment.
prompt_eriner_segment() {
  print -n "%K{$1}"
  if [[ -n ${prompt_eriner_bg} ]]; then
    print -n "%F{${prompt_eriner_bg}}"
  fi
  print -n "$2"
  prompt_eriner_bg=$1
}

# End the prompt, closing last segment.
prompt_eriner_end() {
  print -n "%k%F{${prompt_eriner_bg}}%f "
}

### Prompt components
# Each component will draw itself, or hide itself if no information needs to be
# shown.

# Status: Was there an error? Am I root? Are there background jobs? Ranger
# spawned shell? Who and where am I (user@hostname)?
prompt_eriner_status() {
  local segment=''
  (( ${RETVAL} )) && segment+=' %F{red}✘'
  (( ${UID} == 0 )) && segment+=' %F{yellow}⚡'
  (( $(jobs -l | wc -l) > 0 )) && segment+=' %F{cyan}⚙'
  (( ${RANGER_LEVEL} )) && segment+=' %F{cyan}r'
  if [[ ${USER} != ${DEFAULT_USER} || -n ${SSH_CLIENT} ]]; then
     segment+=' %F{%(!.yellow.default)}${USER}@%m'
  fi
  if [[ -n ${segment} ]]; then
    prompt_eriner_segment black "${segment} "
  fi
}

# Pwd: current working directory.
prompt_eriner_pwd() {
  prompt_eriner_segment cyan " %F{black}$(short_pwd) "
}

# Git: branch/detached head, dirty status.
prompt_eriner_git() {
  if [[ -n ${git_info} ]]; then
    local indicator
    [[ ${git_info[color]} == yellow ]] && indicator='± '
    prompt_eriner_segment ${git_info[color]} ' %F{black}${(e)git_info[prompt]} ${indicator}'
  fi
}

### Main prompt
prompt_eriner_main() {
  RETVAL=$?
  prompt_eriner_status
  prompt_eriner_pwd
  prompt_eriner_git
  prompt_eriner_end
}

prompt_eriner_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_eriner_setup() {
  autoload -Uz colors && colors
  autoload -Uz add-zsh-hook

  prompt_opts=(cr percent subst)

  add-zsh-hook precmd prompt_eriner_precmd

  zstyle ':zim:git-info:branch' format ' %b'
  zstyle ':zim:git-info:commit' format '➦ %c'
  zstyle ':zim:git-info:action' format ' (%s)'
  zstyle ':zim:git-info:clean' format 'green'
  zstyle ':zim:git-info:dirty' format 'yellow'
  zstyle ':zim:git-info:keys' format \
    'prompt' '%b%c%s' \
    'color' '%C%D'

  PROMPT='${(e)$(prompt_eriner_main)}'
  RPROMPT=''
}

prompt_eriner_setup "$@"

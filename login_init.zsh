

#
# startup file read in interactive login shells
#
# The following code helps us by optimizing the existing framework.
# This includes zcompile, zcompdump, etc.
#

(
  local file
  local zmodule
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  autoload -U zrecompile

  # zcompile the completion cache; siginificant speedup
  zrecompile -pq ${ZDOTDIR:-${HOME}}/${zcompdump_file:-.zcompdump}

  # zcompile .zshrc
  zrecompile -pq ${ZDOTDIR:-${HOME}}/.zshrc

  # zcompile enabled module autoloaded functions
  zrecompile -pq ${ZIM_HOME}/functions ${ZIM_HOME}/modules/${^zmodules}/functions/^([_.]*|prompt_*_setup|README*|*.zwc)(-.N)

  # zcompile enabled module init scripts
  for zmodule (${zmodules}); do
    zrecompile -pq ${ZIM_HOME}/modules/${zmodule}/init.zsh
  done

  # zcompile all prompt setup scripts
  for file in ${ZIM_HOME}/modules/prompt/functions/prompt_*_setup; do
    zrecompile -pq ${file}
  done

  # syntax-highlighting
  for file in ${ZIM_HOME}/modules/syntax-highlighting/external/highlighters/**^test-data/*.zsh; do
    zrecompile -pq ${file}
  done
  zrecompile -pq ${ZIM_HOME}/modules/syntax-highlighting/external/zsh-syntax-highlighting.zsh

  # zsh-histery-substring-search
  zrecompile -pq ${ZIM_HOME}/modules/history-substring-search/external/zsh-history-substring-search.zsh

) &!

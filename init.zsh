#
# Zim initializition
#

autoload -Uz is-at-least
if ! is-at-least 5.2; then
  print "ERROR: Zim didn't start. You're using zsh version ${ZSH_VERSION}, and versions < 5.2 are not supported. Update your zsh." >&2
  return 1
fi

# Define zim location
(( ! ${+ZIM_HOME} )) && export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Source user configuration
[[ -s ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc

# Autoload module functions
() {
  local mod_function
  setopt LOCAL_OPTIONS EXTENDED_GLOB

  # autoload searches fpath for function locations; add enabled module function paths
  fpath=(${ZIM_HOME}/functions.zwc ${ZIM_HOME}/modules/prompt/functions ${fpath})

  for mod_function in ${ZIM_HOME}/modules/${^zmodules}/functions/^([_.]*|prompt_*_setup|README*)(-.N:t); do
    autoload -Uz ${mod_function}
  done
}

# Initialize modules
() {
  local zmodule

  for zmodule (${zmodules}); do
    if [[ -s ${ZIM_HOME}/modules/${zmodule}/init.zsh ]]; then
      source ${ZIM_HOME}/modules/${zmodule}/init.zsh
    elif [[ ! -d ${ZIM_HOME}/modules/${zmodule} ]]; then
      print "No such module \"${zmodule}\"." >&2
    fi
  done
}

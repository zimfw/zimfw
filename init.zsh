#
# Zim initializition
#

autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print "ERROR: Zim didn't start. You're using zsh version ${ZSH_VERSION}, and versions < 5.2 are not supported. Update your zsh." >&2
  return 1
fi

# Define zim location
(( ! ${+ZIM_HOME} )) && export ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Source user configuration
[[ -s ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc

# Set input mode before loading modules
if [[ ${zinput_mode} == 'vi' ]]; then
  bindkey -v
else
  bindkey -e
fi

# Autoload module functions
() {
  local mod_function
  setopt LOCAL_OPTIONS EXTENDED_GLOB

  # autoload searches fpath for function locations; add enabled module function paths
  fpath=(${ZIM_HOME}/modules/${^zmodules}/functions(/FN) ${fpath})

  for mod_function in ${ZIM_HOME}/modules/${^zmodules}/functions/^(_*|prompt_*_setup|*.*)(-.N:t); do
    autoload -Uz ${mod_function}
  done
}

# Initialize modules
() {
  local zmodule zmodule_dir zmodule_file

  for zmodule in ${zmodules}; do
    zmodule_dir=${ZIM_HOME}/modules/${zmodule}
    if [[ ! -d ${zmodule_dir} ]]; then
      print "No such module \"${zmodule}\"." >&2
    else
      for zmodule_file in ${zmodule_dir}/init.zsh \
          ${zmodule_dir}/{,zsh-}${zmodule}.{zsh,plugin.zsh,zsh-theme,sh}; do
        if [[ -f ${zmodule_file} ]]; then
          source ${zmodule_file}
          break
        fi
      done
    fi
  done
}

zmanage() {
  local usage="zmanage [action]
Actions:
  update       Fetch and merge upstream zim commits if possible
  info         Print zim and system info
  issue        Create a template for reporting an issue
  clean-cache  Clean the zim cache
  build-cache  Rebuild the zim cache
  remove       *experimental* Remove zim as best we can
  reset        Reset zim to the latest commit
  debug        Invoke the trace-zim script which produces logs
  help         Print this usage message"

  if (( ${#} != 1 )); then
    print ${usage}
    return 1
  fi

  case ${1} in
    update)      zsh ${ZIM_HOME}/tools/zim_update
                 ;;
    info)        zsh ${ZIM_HOME}/tools/zim_info
                 ;;
    issue)       zsh ${ZIM_HOME}/tools/zim_issue
                 ;;
    clean-cache) source ${ZIM_HOME}/tools/zim_clean_cache && print 'Cache cleaned'
                 ;;
    build-cache) source ${ZIM_HOME}/tools/zim_build_cache && print 'Cache rebuilt'
                 ;;
    remove)      zsh ${ZIM_HOME}/tools/zim_remove
                 ;;
    reset)       zsh ${ZIM_HOME}/tools/zim_reset
                 ;;
    debug)       zsh ${ZIM_HOME}/modules/debug/functions/trace-zim
                 ;;
    *)           print ${usage}; return 1
                 ;;
  esac
}

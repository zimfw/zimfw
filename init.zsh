autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 "init: error starting Zim: You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Update your Zsh."
  return 1
fi

# Define Zim location
: ${ZIM_HOME=${0:h}}

# Source user configuration
[[ -f ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc

# Set input mode before loading modules
if zstyle -t ':zim:input' mode 'vi'; then
  bindkey -v
else
  bindkey -e
fi

# Autoload enabled modules' functions
() {
  local zfunction
  local -a zmodules
  zstyle -a ':zim' modules 'zmodules'

  setopt LOCAL_OPTIONS EXTENDED_GLOB
  fpath=(${ZIM_HOME}/modules/${^zmodules}/functions(/FN) ${fpath})
  for zfunction in ${ZIM_HOME}/modules/${^zmodules}/functions/^(_*|*.*|prompt_*_setup)(-.N:t); do
    autoload -Uz ${zfunction}
  done
}

# Source enabled modules' init scripts
() {
  local zmodule zdir zfile
  local -a zmodules
  zstyle -a ':zim' modules 'zmodules'

  for zmodule in ${zmodules}; do
    zdir=${ZIM_HOME}/modules/${zmodule}
    if [[ ! -d ${zdir} ]]; then
      print -u2 "init: module ${zmodule} not installed"
    else
      for zfile in ${zdir}/{init.zsh,${zmodule}.{zsh,plugin.zsh,zsh-theme,sh}}; do
        if [[ -f ${zfile} ]]; then
          source ${zfile}
          break
        fi
      done
    fi
  done
}

_zimfw_compile() {
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  autoload -U zrecompile

  local zdir zfile
  local -a zmodules
  zstyle -a ':zim' modules 'zmodules'

  # Compile the completion cache; significant speedup
  local zdumpfile
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile="${ZDOTDIR:-${HOME}}/.zcompdump"
  [[ -f ${zdumpfile} ]] && zrecompile -p ${1} ${zdumpfile}

  # Compile .zshrc
  zrecompile -p ${1} ${ZDOTDIR:-${HOME}}/.zshrc

  # Compile enabled modules' autoloaded functions
  for zdir in ${ZIM_HOME}/modules/${^zmodules}/functions(/FN); do
    zrecompile -p ${1} ${zdir}.zwc ${zdir}/^(_*|*.*|prompt_*_setup)(-.N)
  done

  # Compile enabled modules' scripts
  for zfile in ${ZIM_HOME}/modules/${^zmodules}/(^*test*/)#*.zsh{,-theme}(.NLk+1); do
    zrecompile -p ${1} ${zfile}
  done

  # Compile this script
  zrecompile -p ${1} ${ZIM_HOME}/init.zsh

  if [[ ${1} != -q ]]; then
    print -P '%F{green}✓%f Done with compile.'
  fi
}

zimfw() {
  if [[ ${#} -ne 1 && ${2} != -q ]]; then
    source ${ZIM_HOME}/tools/usage.zsh
    return 1
  fi

  case ${1} in
    clean)
      source ${ZIM_HOME}/tools/clean-modules.zsh ${2} && \
          source ${ZIM_HOME}/tools/clean-compiled.zsh ${2} && \
          source ${ZIM_HOME}/tools/clean-dumpfile.zsh ${2}
      ;;
    clean-modules) source ${ZIM_HOME}/tools/clean-modules.zsh ${2} ;;
    clean-compiled) source ${ZIM_HOME}/tools/clean-compiled.zsh ${2} ;;
    clean-dumpfile) source ${ZIM_HOME}/tools/clean-dumpfile.zsh ${2} ;;
    compile|login-init) _zimfw_compile ${2} ;;
    info) source ${ZIM_HOME}/tools/info.zsh ${2} ;;
    install|update)
      # Source .zimrc to refresh zmodules
      [[ -f ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc
      source ${ZIM_HOME}/tools/modules.zsh ${2} | xargs -L1 -P10 zsh ${ZIM_HOME}/tools/${1}.zsh && \
          if [[ ${2} != -q ]]; then
            print -P "%F{green}✓%f Done with ${1}. Restart your terminal for any changes to take effect."
          fi
      ;;
    upgrade)
      zsh ${ZIM_HOME}/tools/update.zsh 'https://github.com/zimfw/zimfw.git' ${ZIM_HOME} branch develop ${2}
      ;;
    *)
      source ${ZIM_HOME}/tools/usage.zsh
      return 1
      ;;
  esac
}

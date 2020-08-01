# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2015-2016 Matt Hamilton and contributors
# Copyright (c) 2016-2020 Eric Nielsen, Matt Hamilton and contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 -PR "%F{red}${0}: Error starting Zim. You're using Zsh version %B${ZSH_VERSION}%b and versions < %B5.2%b are not supported. Upgrade your Zsh.%f"
  return 1
fi

# Define Zim location
: ${ZIM_HOME=${0:A:h}}

_zimfw_print() {
  if (( _zprintlevel > 0 )) print "${@}"
}

_zimfw_mv() {
  local -a cklines
  if cklines=(${(f)"$(command cksum ${1} ${2} 2>/dev/null)"}) && \
      [[ ${${(z)cklines[1]}[1,2]} == ${${(z)cklines[2]}[1,2]} ]]; then
    _zimfw_print -PR "%F{green})%f %B${2}:%b Already up to date"
  else
    if [[ -e ${2} ]]; then
      command mv -f ${2}{,.old} || return 1
    fi
    command mv -f ${1} ${2} && \
        _zimfw_print -PR "%F{green})%f %B${2}:%b Updated. Restart your terminal for changes to take effect."
  fi
}

_zimfw_build_init() {
  local -r ztarget=${ZIM_HOME}/init.zsh
  # Force update of init.zsh if it's older than .zimrc
  if [[ ${ztarget} -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    command mv -f ${ztarget}{,.old} || return 1
  fi
  _zimfw_mv =(
    print -R "zimfw() { source ${ZIM_HOME}/zimfw.zsh \"\${@}\" }"
    if (( ${#_zfpaths} )) print -R 'fpath=('${_zfpaths:A}' ${fpath})'
    if (( ${#_zfunctions} )) print -R 'autoload -Uz '${_zfunctions}
    print -R ${(F)_zcmds}
  ) ${ztarget}
}

_zimfw_build_login_init() {
  # Array with unique dirs. ${ZIM_HOME} or any subdirectory should only occur once.
  local -Ur zscriptdirs=(${ZIM_HOME} ${${_zdirs##${ZIM_HOME}/*}:A})
  local -r zscriptglob=("${^zscriptdirs[@]}/(^*test*/)#*.zsh(|-theme)(N-.)")
  local -r ztarget=${ZIM_HOME}/login_init.zsh
  _zimfw_mv =(
    print -Rn "() {
  setopt LOCAL_OPTIONS CASE_GLOB EXTENDED_GLOB
  autoload -Uz zrecompile
  local zdumpfile zfile

  # Compile the completion cache; significant speedup
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile=\${ZDOTDIR:-\${HOME}}/.zcompdump
  if [[ -f \${zdumpfile} ]]; then
    zrecompile -p \${1} \${zdumpfile} || return 1
  fi

  # Compile Zsh startup files
  for zfile in \${ZDOTDIR:-\${HOME}}/.z(shenv|profile|shrc|login|logout)(N-.); do
    zrecompile -p \${1} \${zfile} || return 1
  done

  # Compile Zim scripts
  for zfile in ${zscriptglob}; do
    zrecompile -p \${1} \${zfile} || return 1
  done

  if [[ \${1} != -q ]] print -P 'Done with compile.'
} \"\${@}\"
"
  ) ${ztarget}
}

_zimfw_build() {
  _zimfw_build_init && _zimfw_build_login_init && _zimfw_print -P 'Done with build.'
}

zmodule() {
  local -r zusage="Usage: %B${0}%b <url> [%B-n%b|%B--name%b <module_name>] [options]

Add %Bzmodule%b calls to your %B${ZDOTDIR:-${HOME}}/.zimrc%b file to define the modules to be initialized.
The modules are initialized in the same order they are defined.

  <url>                          Module absolute path or repository URL. The following URL formats
                                 are equivalent: %Bname%b, %Bzimfw/name%b, %Bhttps://github.com/zimfw/name.git%b.
  %B-n%b|%B--name%b <module_name>        Set a custom module name. Default: the last component in the <url>.

Repository options:
  %B-b%b|%B--branch%b <branch_name>      Use specified branch when installing and updating the module.
                                 Overrides the tag option. Default: %Bmaster%b.
  %B-t%b|%B--tag%b <tag_name>            Use specified tag when installing and updating the module.
                                 Overrides the branch option.
  %B-z%b|%B--frozen%b                    Don't install or update the module.

Initialization options:
  %B-f%b|%B--fpath%b <path>              Add specified path to fpath. The path is relative to the module
                                 root directory. Default: %Bfunctions%b, if the subdirectory exists.
  %B-a%b|%B--autoload%b <function_name>  Autoload specified function. Default: all valid names inside the
                                 module's specified fpath paths.
  %B-s%b|%B--source%b <file_path>        Source specified file. The file path is relative to the module root
                                 directory. Default: the file with largest size matching
                                 %B{init.zsh,module_name.{zsh,plugin.zsh,zsh-theme,sh}}%b, if any exist.
  %B-c%b|%B--cmd%b <command>             Execute specified command. Occurrences of the %B{}%b placeholder in the
                                 command are substituted by the module root directory path.
                                 %B-s 'script.zsh'%b and %B-c 'source {}/script.zsh'%b are equivalent.
  %B-d%b|%B--disabled%b                  Don't initialize or uninstall the module.
"
  if [[ ${${funcfiletrace[1]%:*}:t} != .zimrc ]]; then
    print -u2 -PR "%F{red}${0}: Must be called from %B${ZDOTDIR:-${HOME}}/.zimrc%b%f"$'\n\n'${zusage}
    return 1
  fi
  if (( ! # )); then
    print -u2 -PR "%F{red}x ${funcfiletrace[1]}: Missing zmodule url%f"$'\n\n'${zusage}
    _zfailed=1
    return 1
  fi
  setopt LOCAL_OPTIONS CASE_GLOB EXTENDED_GLOB
  local zmodule=${1:t} zurl=${1}
  local ztype=branch zrev=master
  local -i zdisabled=0 zfrozen=0
  local -a zfpaths zfunctions zcmds
  local zarg zdir
  if [[ ${zurl} =~ ^[^:/]+: ]]; then
    zmodule=${zmodule%.git}
  elif [[ ${zurl} != /* ]]; then
    # Count number of slashes
    case ${#zurl//[^\/]/} in
      0) zurl="https://github.com/zimfw/${zurl}.git" ;;
      1) zurl="https://github.com/${zurl}.git" ;;
    esac
  fi
  shift
  if [[ ${1} == (-n|--name) ]]; then
    if (( # < 2 )); then
      print -u2 -PR "%F{red}x ${funcfiletrace[1]}:%B${zmodule}:%b Missing argument for zmodule option ${1}%f"$'\n\n'${zusage}
      _zfailed=1
      return 1
    fi
    shift
    zmodule=${1}
    shift
  fi
  if [[ ${zurl} == /* ]]; then
    zdir=${zurl}
  else
    zdir=${ZIM_HOME}/modules/${zmodule}
  fi
  while (( # > 0 )); do
    case ${1} in
      -b|--branch|-t|--tag|-f|--fpath|-a|--autoload|-s|--source)
        if (( # < 2 )); then
          print -u2 -PR "%F{red}x ${funcfiletrace[1]}:%B${zmodule}:%b Missing argument for zmodule option ${1}%f"$'\n\n'${zusage}
          _zfailed=1
          return 1
        fi
        ;;
    esac
    case ${1} in
      -b|--branch)
        shift
        ztype=branch
        zrev=${1}
        ;;
      -t|--tag)
        shift
        ztype=tag
        zrev=${1}
        ;;
      -z|--frozen) zfrozen=1 ;;
      -f|--fpath)
        shift
        zarg=${1}
        if [[ ${zarg} != /* ]] zarg=${zdir}/${zarg}
        zfpaths+=(${zarg})
        ;;
      -a|--autoload)
        shift
        zfunctions+=(${1})
        ;;
      -s|--source)
        shift
        zarg=${1}
        if [[ ${zarg} != /* ]] zarg=${zdir}/${zarg}
        zcmds+=("source ${zarg:A}")
        ;;
      -c|--cmd)
        shift
        zcmds+=(${1//{}/${zdir:A}})
        ;;
      -d|--disabled) zdisabled=1 ;;
      *)
        print -u2 -PR "%F{red}x ${funcfiletrace[1]}:%B${zmodule}:%b Unknown zmodule option ${1}%f"$'\n\n'${zusage}
        _zfailed=1
        return 1
        ;;
    esac
    shift
  done
  if (( _zprepare_zargs )); then
    if (( ! zfrozen )); then
      _zmodules_zargs+=(${zmodule} ${zdir} ${zurl} ${ztype} ${zrev} ${_zprintlevel})
    fi
  else
    if (( zdisabled )); then
      _zdisableds+=(${zmodule})
    else
      if [[ ! -d ${zdir} ]]; then
        print -u2 -PR "%F{red}x ${funcfiletrace[1]}:%B${zmodule}:%b Not installed. Run %Bzimfw install%b to install.%f"
        _zfailed=1
        return 1
      fi
      if (( ! ${#zfpaths} )) zfpaths+=(${zdir}/functions(NF))
      if (( ! ${#zfunctions} )); then
        # _* functions are autoloaded by compinit
        # prompt_*_setup functions are autoloaded by promptinit
        zfunctions+=(${^zfpaths}/^(*~|*.zwc(|.old)|_*|prompt_*_setup)(N-.:t))
      fi
      if (( ! ${#zcmds} )); then
        local -r zscript=(${zdir}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
        zcmds+=("source ${^zscript[@]:A}")
      fi
      if (( ! ${#zfpaths} && ! ${#zfunctions} && ! ${#zcmds} )); then
        print -u2 -PR "%F{yellow}! ${funcfiletrace[1]}:%B${zmodule}:%b Nothing found to be initialized. Customize the module name or initialization with %Bzmodule%b options.%f"$'\n\n'${zusage}
      fi
      _zmodules+=(${zmodule})
      _zdirs+=(${zdir})
      _zfpaths+=(${zfpaths})
      _zfunctions+=(${zfunctions})
      _zcmds+=(${zcmds})
    fi
  fi
}

_zimfw_source_zimrc() {
  local -r ztarget=${ZDOTDIR:-${HOME}}/.zimrc
  local -ri _zprepare_zargs=${1}
  local -i _zfailed=0
  if ! source ${ztarget} || (( _zfailed )); then
    print -u2 -PR "%F{red}Failed to source %B${ztarget}%b%f"
    return 1
  fi
  if (( _zprepare_zargs && ! ${#_zmodules_zargs} )); then
    print -u2 -PR "%F{red}No modules defined in %B${ztarget}%b%f"
    return 1
  fi
}

_zimfw_version_check() {
  if (( _zprintlevel > 0 )); then
    setopt LOCAL_OPTIONS EXTENDED_GLOB
    local -r ztarget=${ZIM_HOME}/.latest_version
    # If .latest_version does not exist or was not modified in the last 30 days
    if [[ -w ${ztarget:h} && ! -f ${ztarget}(#qNm-30) ]]; then
      command git ls-remote --tags --refs https://github.com/zimfw/zimfw.git 'v*' | \
          command sed 's?^.*/v??' | command sort -n -t. -k1,1 -k2,2 -k3,3 | \
          command tail -n1 >! ${ztarget} &!
    fi
    if [[ -f ${ztarget} ]]; then
      local -r zlatest_version=$(<${ztarget})
      if [[ -n ${zlatest_version} && ${_zversion} != ${zlatest_version} ]]; then
        print -u2 -PR "%F{yellow}Latest zimfw version is %B${zlatest_version}%b. You're using version %B${_zversion}%b. Run %Bzimfw upgrade%b to upgrade.%f"$'\n'
      fi
    fi
  fi
}

_zimfw_clean_compiled() {
  # Array with unique dirs. ${ZIM_HOME} or any subdirectory should only occur once.
  local -Ur zscriptdirs=(${ZIM_HOME} ${${_zdirs##${ZIM_HOME}/*}:A})
  local zopt
  if (( _zprintlevel > 0 )) zopt='-v'
  command rm -f ${zopt} ${^zscriptdirs}/**/*.zwc(|.old)(N) || return 1
  command rm -f ${zopt} ${ZDOTDIR:-${HOME}}/.z(shenv|profile|shrc|login|logout).zwc(|.old)(N) || return 1
  _zimfw_print -P 'Done with clean-compiled. Run %Bzimfw compile%b to re-compile.'
}

_zimfw_clean_dumpfile() {
  local zdumpfile zopt
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile=${ZDOTDIR:-${HOME}}/.zcompdump
  if (( _zprintlevel > 0 )) zopt='-v'
  command rm -f ${zopt} ${zdumpfile}(|.zwc(|.old))(N) || return 1
  _zimfw_print -P 'Done with clean-dumpfile. Restart your terminal to dump an updated configuration.'
}

_zimfw_compile() {
  local zopt
  if (( _zprintlevel <= 0 )) zopt='-q'
  source ${ZIM_HOME}/login_init.zsh ${zopt}
}

_zimfw_info() {
  print -R 'zimfw version: '${_zversion}' (previous commit is ccace0c)'
  print -R 'ZIM_HOME:      '${ZIM_HOME}
  print -R 'Zsh version:   '${ZSH_VERSION}
  print -R 'System info:   '$(command uname -a)
}

_zimfw_uninstall() {
  local zopt zdir zmodule
  if (( _zprintlevel > 0 )) zopt='-v'
  for zdir in ${ZIM_HOME}/modules/*(N/); do
    zmodule=${zdir:t}
    # If _zmodules and _zdisableds do not contain the zmodule
    if (( ! ${_zmodules[(I)${zmodule}]} && ! ${_zdisableds[(I)${zmodule}]} )); then
      command rm -rf ${zopt} ${zdir} || return 1
    fi
  done
  _zimfw_print -P 'Done with uninstall.'
}

_zimfw_upgrade() {
  local -r ztarget=${ZIM_HOME}/zimfw.zsh
  local -r zurl=https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh.gz
  {
    if (( ${+commands[curl]} )); then
      command curl -fsSL -o ${ztarget}.new.gz ${zurl} || return 1
    else
      local zopt
      if (( _zprintlevel <= 1 )) zopt='-q'
      if ! command wget -nv ${zopt} -O ${ztarget}.new.gz ${zurl}; then
        if (( _zprintlevel <= 1 )) print -u2 -PR "%F{red}x Error downloading %B${zurl}%b. Use %B-v%b option to see details.%f"
        return 1
      fi
    fi
    command gunzip -f ${ztarget}.new.gz || return 1
    # .latest_version can be outdated and will yield a false warning if zimfw is
    # upgraded before .latest_version is refreshed. Bad thing about having a cache.
    _zimfw_mv ${ztarget}{.new,} && command rm -f ${ZIM_HOME}/.latest_version && \
        _zimfw_print -P 'Done with upgrade.'
  } always {
    command rm -f ${ztarget}.new{,.gz}
  }
}

zimfw() {
  local -r _zversion='1.3.2'
  local -r zusage="Usage: %B${0}%b <action> [%B-q%b|%B-v%b]

Actions:
  %Bbuild%b           Build %Binit.zsh%b and %Blogin_init.zsh%b
  %Bclean%b           Clean all (see below)
  %Bclean-compiled%b  Clean Zsh compiled files
  %Bclean-dumpfile%b  Clean completion dump file
  %Bcompile%b         Compile Zsh files
  %Bhelp%b            Print this help
  %Binfo%b            Print Zim and system info
  %Binstall%b         Install new modules
  %Buninstall%b       Delete unused modules
  %Bupdate%b          Update current modules
  %Bupgrade%b         Upgrade %Bzimfw.zsh%b
  %Bversion%b         Print Zim version

Options:
  %B-q%b              Quiet, only outputs errors
  %B-v%b              Verbose
"
  local ztool
  local -a _zdisableds _zmodules _zdirs _zfpaths _zfunctions _zcmds _zmodules_zargs
  local -i _zprintlevel=1
  if (( # > 2 )); then
     print -u2 -PR "%F{red}${0}: Too many options%f"$'\n\n'${zusage}
     return 1
  elif (( # > 1 )); then
    case ${2} in
      -q) _zprintlevel=0 ;;
      -v) _zprintlevel=2 ;;
      *)
        print -u2 -PR "%F{red}${0}: Unknown option ${2}%f"$'\n\n'${zusage}
        return 1
        ;;
    esac
  fi

  if ! zstyle -t ':zim' disable-version-check; then
    _zimfw_version_check
  fi

  case ${1} in
    install)
      ztool="# This runs in a new shell
readonly MODULE=\${1}
readonly DIR=\${2}
readonly URL=\${3}
readonly REV=\${5}
readonly -i PRINTLEVEL=\${6}
readonly CLEAR_LINE=$'\E[2K\r'
if [[ -e \${DIR} ]]; then
  # Already exists
  return 0
fi
if (( PRINTLEVEL > 0 )) print -Rn \${CLEAR_LINE}\"Installing \${MODULE} ...\"
if ERR=\$(command git clone -b \${REV} -q --recursive \${URL} \${DIR} 2>&1); then
  if (( PRINTLEVEL > 0 )) print -PR \${CLEAR_LINE}\"%F{green})%f %B\${MODULE}:%b Installed\"
else
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b Error during git clone%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
"
      ;;
    update)
      ztool="# This runs in a new shell
readonly MODULE=\${1}
readonly DIR=\${2}
readonly URL=\${3}
readonly TYPE=\${4}
readonly REV=\${5}
readonly -i PRINTLEVEL=\${6}
readonly CLEAR_LINE=$'\E[2K\r'
if (( PRINTLEVEL > 0 )) print -Rn \${CLEAR_LINE}\"Updating \${MODULE} ...\"
if ! builtin cd -q \${DIR} 2>/dev/null; then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b Not installed. Run %Bzimfw install%b to install.%f\"
  return 1
fi
if [[ \${PWD} != \$(command git rev-parse --show-toplevel 2>/dev/null) ]]; then
  # Not in repo root. Will not try to update.
  return 0
fi
if [[ \${URL} != \$(command git config --get remote.origin.url) ]]; then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b URL does not match. Expected \${URL}. Will not try to update.%f\"
  return 1
fi
if [[ \${TYPE} == tag ]]; then
  if [[ \${REV} == \$(command git describe --tags --exact-match 2>/dev/null) ]]; then
    if (( PRINTLEVEL > 0 )) print -PR \${CLEAR_LINE}\"%F{green})%f %B\${MODULE}:%b Already up to date\"
    return 0
  fi
fi
if ! ERR=\$(command git fetch -pq origin \${REV} 2>&1); then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b Error during git fetch%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
if [[ \${TYPE} == branch ]]; then
  LOG_REV=\${REV}@{u}
else
  LOG_REV=\${REV}
fi
LOG=\$(command git log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..\${LOG_REV} 2>/dev/null)
if ! ERR=\$(command git checkout -q \${REV} -- 2>&1); then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b Error during git checkout%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
if [[ \${TYPE} == branch ]]; then
  if ! OUT=\$(command git merge --ff-only --no-progress -n 2>&1); then
    print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b Error during git merge%f\"$'\n'\${(F):-  \${(f)^OUT}}
    return 1
  fi
  # keep just first line of OUT
  OUT=\${OUT%%($'\n'|$'\r')*}
else
  OUT=\"Updating to \${TYPE} \${REV}\"
fi
if ERR=\$(command git submodule update --init --recursive -q 2>&1); then
  if (( PRINTLEVEL > 0 )); then
    if [[ -n \${LOG} ]] OUT=\${OUT}$'\n'\${(F):-  \${(f)^LOG}}
    print -PR \${CLEAR_LINE}\"%F{green})%f %B\${MODULE}:%b \${OUT}\"
  fi
else
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b Error during git submodule update%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
"
      ;;
  esac

  case ${1} in
    build)
      _zimfw_source_zimrc && _zimfw_build || return 1
      (( _zprintlevel-- ))
      _zimfw_compile
      ;;
    init) _zimfw_source_zimrc && _zimfw_build ;;
    clean) _zimfw_source_zimrc && _zimfw_clean_compiled && _zimfw_clean_dumpfile ;;
    clean-compiled) _zimfw_source_zimrc && _zimfw_clean_compiled ;;
    clean-dumpfile) _zimfw_clean_dumpfile ;;
    compile) _zimfw_source_zimrc && _zimfw_build_login_init && _zimfw_compile ;;
    help) print -PR ${zusage} ;;
    info) _zimfw_info ;;
    install|update)
      _zimfw_source_zimrc 1 || return 1
      autoload -Uz zargs && \
          zargs -n 9 -P 10 -- ${_zmodules_zargs} -- zsh -c ${ztool} ${1} && \
          _zimfw_print -PR "Done with ${1}. Restart your terminal for any changes to take effect." || return 1
      (( _zprintlevel-- ))
      _zimfw_source_zimrc && _zimfw_build && _zimfw_compile
      ;;
    uninstall) _zimfw_source_zimrc && _zimfw_uninstall ;;
    upgrade)
      _zimfw_upgrade || return 1
      (( _zprintlevel-- ))
      _zimfw_compile
      ;;
    version) print -PR ${_zversion} ;;
    *)
      print -u2 -PR "%F{red}${0}: Unknown action ${1}%f"$'\n\n'${zusage}
      return 1
      ;;
  esac
}

zimfw "${@}"

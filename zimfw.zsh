# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2015-2016 Matt Hamilton and contributors
# Copyright (c) 2016-2021 Eric Nielsen, Matt Hamilton and contributors
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
if (( ! ${+ZIM_HOME} )) typeset -g ZIM_HOME=${0:A:h}

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
  local -r zscriptglob=("${^zscriptdirs[@]}/(^*test*/)#*.zsh(|-theme)(N-.)") ztarget=${ZIM_HOME}/login_init.zsh
  # Force update of login_init.zsh if it's older than .zimrc
  if [[ ${ztarget} -ot ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    command mv -f ${ztarget}{,.old} || return 1
  fi
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

  <url>                      Module absolute path or repository URL. The following URL formats
                             are equivalent: %Bname%b, %Bzimfw/name%b, %Bhttps://github.com/zimfw/name.git%b.
  %B-n%b|%B--name%b <module_name>    Set a custom module name. Default: the last component in the <url>.
                             Use slashes inside the name to organize the module into subdirecto-
                             ries.

Repository options:
  %B-b%b|%B--branch%b <branch_name>  Use specified branch when installing and updating the module.
                             Overrides the tag option. Default: the repository's default branch.
  %B-t%b|%B--tag%b <tag_name>        Use specified tag when installing and updating the module.
                             Overrides the branch option.
  %B-u%b|%B--use%b <%Bgit%b|%Bdegit%b>       Install and update the module using the defined tool. Default is
                             defined by %Bzstyle ':zim:zmodule' use '%b<%Bgit%b|%Bdegit%b>%B'%b, or %Bgit%b if none
                             is provided.
                             %Bgit%b requires git itself. Local changes are preserved during updates.
                             %Bdegit%b requires curl or wget, and currently only works with GitHub
                             URLs. Modules install faster and take less disk space. Local changes
                             are lost during updates. Git submodules are not supported.
  %B-z%b|%B--frozen%b                Don't install or update the module.

Initialization options:
  %B-f%b|%B--fpath%b <path>          Add specified path to fpath. The path is relative to the module
                             root directory. Default: %Bfunctions%b, if the subdirectory exists.
  %B-a%b|%B--autoload%b <func_name>  Autoload specified function. Default: all valid names inside the
                             module's specified fpath paths.
  %B-s%b|%B--source%b <file_path>    Source specified file. The file path is relative to the module root
                             directory. Default: %Binit.zsh%b, if the %Bfunctions%b subdirectory also
                             exists, or the file with largest size matching
                             %B{init.zsh,module_name.{zsh,plugin.zsh,zsh-theme,sh}}%b, if any exist.
  %B-c%b|%B--cmd%b <command>         Execute specified command. Occurrences of the %B{}%b placeholder in the
                             command are substituted by the module root directory path.
                             I.e., %B-s 'script.zsh'%b and %B-c 'source {}/script.zsh'%b are equivalent.
  %B-d%b|%B--disabled%b              Don't initialize or uninstall the module."
  if [[ ${${funcfiletrace[1]%:*}:t} != .zimrc ]]; then
    print -u2 -PR "%F{red}${0}: Must be called from %B${ZDOTDIR:-${HOME}}/.zimrc%b%f"$'\n\n'${zusage}
    return 2
  fi
  if (( ! # )); then
    print -u2 -PR "%F{red}x ${funcfiletrace[1]}: Missing zmodule url%f"$'\n\n'${zusage}
    _zfailed=1
    return 2
  fi
  setopt LOCAL_OPTIONS CASE_GLOB EXTENDED_GLOB
  local zurl=${1} zmodule=${1:t} ztool zdir ztype zrev zarg
  local -i zdisabled=0 zfrozen=0
  local -a zfpaths zfunctions zcmds
  zstyle -s ':zim:zmodule' use 'ztool' || ztool=git
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
      return 2
    fi
    shift
    zmodule=${${1%%/##}##/##}
    shift
  fi
  if [[ ${zurl} == /* ]]; then
    zdir=${zurl%%/##}
  else
    zdir=${ZIM_HOME}/modules/${zmodule}
  fi
  while (( # > 0 )); do
    case ${1} in
      -b|--branch|-t|--tag|-u|--use|-f|--fpath|-a|--autoload|-s|--source|-c|--cmd)
        if (( # < 2 )); then
          print -u2 -PR "%F{red}x ${funcfiletrace[1]}:%B${zmodule}:%b Missing argument for zmodule option ${1}%f"$'\n\n'${zusage}
          _zfailed=1
          return 2
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
      -u|--use)
        shift
        ztool=${1}
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
        return 2
        ;;
    esac
    shift
  done
  if [[ -n ${_zargs_action} ]]; then
    if (( ! zfrozen )); then
      _zmodules_zargs+=("${ztool}" "${_zargs_action}" "${zmodule}" "${zdir}" "${zurl}" "${ztype}" "${zrev}")
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
      local -ra prezto_fpaths=(${zdir}/functions(NF)) prezto_scripts=(${zdir}/init.zsh(N))
      if (( ! ${#zfpaths} && ! ${#zcmds} && ${#prezto_fpaths} && ${#prezto_scripts} )); then
        # this follows the prezto module format, no need to check for other scripts
        zfpaths=(${prezto_fpaths})
        zcmds=("source ${^prezto_scripts[@]:A}")
      else
        if (( ! ${#zfpaths} )) zfpaths=(${prezto_fpaths})
        if (( ! ${#zcmds} )); then
          # get script with largest size (descending `O`rder by `L`ength, and return only `[1]` first)
          local -ra zscripts=(${zdir}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
          zcmds=("source ${^zscripts[@]:A}")
        fi
      fi
      if (( ! ${#zfunctions} )); then
        # _* functions are autoloaded by compinit
        # prompt_*_setup functions are autoloaded by promptinit
        zfunctions=(${^zfpaths}/^(*~|*.zwc(|.old)|_*|prompt_*_setup)(N-.:t))
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
  local -r ztarget=${ZDOTDIR:-${HOME}}/.zimrc _zargs_action=${1}
  local -i _zfailed=0
  if ! source ${ztarget} || (( _zfailed )); then
    print -u2 -PR "%F{red}Failed to source %B${ztarget}%b%f"
    return 1
  fi
  if [[ -n ${_zargs_action} && ${#_zmodules_zargs} -eq 0 ]]; then
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
      # Get latest version (get all `v*` tags from repo, delete `*v` from beginning,
      # sort in descending `O`rder `n`umerically, and get the `[1]` first)
      print ${${(On)${(f)"$(command git ls-remote --tags --refs \
          https://github.com/zimfw/zimfw.git 'v*' 2>/dev/null)"}##*v}[1]} >! ${ztarget} &!
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
  _zimfw_print -P 'Done with clean-compiled. Restart your terminal or run %Bzimfw compile%b to re-compile.'
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
  print -R 'zimfw version: '${_zversion}' (built at 2021-08-31 23:40:27 UTC, previous commit is e56048f)'
  print -R 'ZIM_HOME:      '${ZIM_HOME}
  print -R 'Zsh version:   '${ZSH_VERSION}
  print -R 'System info:   '$(command uname -a)
}

_zimfw_uninstall() {
  local zopt zuninstalls=(${ZIM_HOME}/modules/*(N/:t))
  if (( _zprintlevel > 0 )) zopt='-v'
  # Search into subdirectories
  local -a subdirs
  local -i i=1
  while (( i <= ${#zuninstalls} )); do
    if (( ${_zmodules[(I)${zuninstalls[i]}/*]} || ${_zdisableds[(I)${zuninstalls[i]}/*]} )); then
      subdirs=(${ZIM_HOME}/modules/${zuninstalls[i]}/*(N/:t))
      zuninstalls+=(${zuninstalls[i]}/${^subdirs})
      zuninstalls[i]=()
    else
      (( i++ ))
    fi
  done
  # Uninstall all installed modules not in _zmodules and _zdisableds
  zuninstalls=(${${zuninstalls:|_zmodules}:|_zdisableds})
  if (( ${#zuninstalls} )); then
    _zimfw_print -PR %B${(F)zuninstalls}%b
    if (( _zprintlevel <= 0 )) || read -q "?Uninstall ${#zuninstalls} module(s) listed above [y/N]? "; then
      _zimfw_print
      command rm -rf ${zopt} ${ZIM_HOME}/modules/${^zuninstalls} || return 1
    fi
  fi
  _zimfw_print -P 'Done with uninstall.'
}

_zimfw_upgrade() {
  local -r ztarget=${ZIM_HOME}/zimfw.zsh zurl=https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh.gz
  {
    if (( ${+commands[curl]} )); then
      command curl -fsSL -o ${ztarget}.new.gz ${zurl} || return 1
    else
      local zopt
      if (( _zprintlevel <= 1 )) zopt='-q'
      if ! command wget -nv ${zopt} -O ${ztarget}.new.gz ${zurl}; then
        if (( _zprintlevel <= 1 )); then
          print -u2 -PR "%F{red}Failed to download %B${zurl}%b. Use %B-v%b option to see details.%f"
        fi
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

_zimfw_run_tool() {
  local -r ztool=${1}
  shift
  local -r zaction=${1} zmodule=${2} zdir=${3} clear_line=$'\E[2K\r'
  case ${zaction} in
    install)
      if [[ -e ${zdir} ]]; then
        # Already installed
        return 0
      fi
      _zimfw_print -Rn ${clear_line}"Installing ${zmodule} ..."
      ;;
    update)
      if [[ ! -d ${zdir} ]]; then
        print -u2 -PR "%F{red}x %B${zmodule}:%b Not installed. Run %Bzimfw install%b to install.%f"
        return 1
      fi
      _zimfw_print -Rn ${clear_line}"Updating ${zmodule} ..."
      ;;
    *)
      print -u2 -PR "%F{red}x %B${zmodule}:%b Unknown action ${zaction}%f"
      return 1
      ;;
  esac
  local zcmd
  case ${ztool} in
    degit) zcmd="# This runs in a new shell
readonly ACTION=\${1} MODULE=\${2} DIR=\${3} URL=\${4} REV=\${6} CLEAR_LINE=$'\E[2K\r'
readonly -i PRINTLEVEL=\${7}
readonly TEMP=.zdegit_\${RANDOM}
readonly TARBALL_TARGET=\${DIR}/\${TEMP}_tarball.tar.gz INFO_TARGET=\${DIR}/.zdegit

print_error() {
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b \${1}%f\"\${2:+$'\n'\${(F):-  \${(f)^2}}}
}

print_okay() {
  if [[ -e \${DIR}/.gitmodules ]]; then
    local -r warn=\${CLEAR_LINE}\"%F{yellow}! %B\${MODULE}:%b \${(C)1}. Module contains git submodules, which are not supported by Zim's degit and were not \${1}.%f\"
    if (( PRINTLEVEL > 0 )); then
      print -PR \${warn}\${2:+$'\n'\${(F):-  \${(f)^2}}}
    else
      print -u2 -PR \${warn}
    fi
  elif (( PRINTLEVEL > 0 )); then
    print -PR \${CLEAR_LINE}\"%F{green})%f %B\${MODULE}:%b \${(C)1}\"\${2:+$'\n'\${(F):-  \${(f)^2}}}
  fi
}

download_tarball() {
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  local host repo
  if [[ \${URL} =~ ^([^:@/]+://)?([^@]+@)?([^:/]+)[:/]([^/]+/[^/]+)/?\$ ]]; then
    host=\${match[3]}
    repo=\${match[4]%.git}
  fi
  if [[ \${host} != github.com || -z \${repo} ]]; then
    print_error \"\${URL} is not a valid GitHub URL. Will not try to \${ACTION}.\"
    return 1
  fi
  local -r headers_target=\${DIR}/\${TEMP}_headers
  {
    local info_header header etag
    if [[ -r \${INFO_TARGET} ]]; then
      local -r info=(\"\${(@f)\"\$(<\${INFO_TARGET})\"}\")
      if [[ \${URL} != \${info[1]} ]]; then
        print_error \"URL does not match. Expected \${URL}. Will not try to \${ACTION}.\"
        return 1
      fi
      # Previous REV is in line 2, reserved for future use.
      info_header=\${info[3]}
    fi
    local -r tarball_url=https://api.github.com/repos/\${repo}/tarball/\${REV}
    if (( \${+commands[curl]} )); then
      if ! ERR=\$(command curl -fsSL \${info_header:+-H} \${info_header} -o \${TARBALL_TARGET} -D \${headers_target} \${tarball_url} 2>&1); then
        print_error \"Error downloading \${tarball_url} with curl\" \${ERR}
        return 1
      fi
    else
      # wget returns 8 when 304 Not Modified, so we cannot use wget's error codes
      command wget -q \${info_header:+--header=\${info_header}} -O \${TARBALL_TARGET} -S \${tarball_url} 2>\${headers_target}
    fi
    local -i http_code
    while IFS= read -r header; do
      header=\${\${header## ##}%%$'\r'##}
      if [[ \${header} == HTTP/* ]]; then
        http_code=\${\${(s: :)header}[2]}
      elif [[ \${\${(L)header%%:*}%% ##} == 'etag' ]]; then
        etag=\${\${header#*:}## ##}
      fi
    done < \${headers_target}
    if (( http_code == 304 )); then
      # Not Modified
      command rm -f \${TARBALL_TARGET} 2>/dev/null
      return 0
    elif (( http_code != 200 )); then
      print_error \"Error downloading \${tarball_url}, HTTP code \${http_code}\"
      return 1
    fi
    if [[ -z \${etag} ]]; then
      print_error \"Error downloading \${tarball_url}, no ETag header found in response\"
      return 1
    fi
    if ! print -R \${URL}$'\n'\${REV}$'\n'\"If-None-Match: \${etag}\" >! \${INFO_TARGET} 2>/dev/null; then
      print_error \"Error creating or updating \${INFO_TARGET}\"
      return 1
    fi
  } always {
    command rm -f \${headers_target} 2>/dev/null
  }
}

untar_tarball() {
  if ! ERR=\$(command tar -C \${1} --strip=1 -xzf \${TARBALL_TARGET} 2>&1); then
    print_error \"Error extracting \${TARBALL_TARGET}\" \${ERR}
    return 1
  fi
}

create_dir() {
  if ! ERR=\$(command mkdir -p \${1} 2>&1); then
    print_error \"Error creating \${1}\" \${ERR}
    return 1
  fi
}

() {
  case \${ACTION} in
    install)
      {
        create_dir \${DIR} && download_tarball && untar_tarball \${DIR} && print_okay installed
      } always {
        # return 1 does not change \${TRY_BLOCK_ERROR}, only changes \${?}
        (( TRY_BLOCK_ERROR = ? ))
        command rm -f \${TARBALL_TARGET} 2>/dev/null
        if (( TRY_BLOCK_ERROR )); then
          command rm -rf \${DIR} 2>/dev/null
        fi
      }
      ;;
    update)
      if [[ -r \${DIR}/.zim_degit_info ]] command mv -f \${DIR}/.zim_degit_info \${INFO_TARGET}
      if [[ ! -r \${INFO_TARGET} ]]; then
        print_error \"Module was not installed using Zim's degit. Will not try to update. You can disable this with the zmodule option -z|--frozen.\"
        return 1
      fi
      local -r dir_new=\${DIR}\${TEMP}
      {
        download_tarball || return 1
        if [[ ! -e \${TARBALL_TARGET} ]]; then
          if (( PRINTLEVEL > 0 )) print -PR \${CLEAR_LINE}\"%F{green})%f %B\${MODULE}:%b Already up to date\"
          return 0
        fi
        create_dir \${dir_new} && untar_tarball \${dir_new} || return 1
        if (( \${+commands[diff]} )); then
          LOG=\$(command diff -x '.zdegit*' -x '*.zwc' -x '*.zwc.old' -qr \${DIR} \${dir_new} 2>/dev/null)
          LOG=\${\${LOG//\${dir_new}/new}//\${DIR}/old}
        fi
        if ! ERR=\$({ command cp -f \${INFO_TARGET} \${dir_new} && \
            command rm -rf \${DIR} && command mv -f \${dir_new} \${DIR} } 2>&1); then
          print_error \"Error updating \${DIR}\" \${ERR}
          return 1
        fi
        print_okay updated \${LOG}
      } always {
        command rm -f \${TARBALL_TARGET} 2>/dev/null
        command rm -rf \${dir_new} 2>/dev/null
      }
      ;;
  esac
}
" ;;
    git) zcmd="# This runs in a new shell
readonly ACTION=\${1} MODULE=\${2} DIR=\${3} URL=\${4} TYPE=\${5:=branch} CLEAR_LINE=$'\E[2K\r'
REV=\${6}
readonly -i PRINTLEVEL=\${7}

print_error() {
  print -u2 -PR \${CLEAR_LINE}\"%F{red}x %B\${MODULE}:%b \${1}%f\"\${2:+$'\n'\${(F):-  \${(f)^2}}}
}

print_okay() {
  if (( PRINTLEVEL > 0 )) print -PR \${CLEAR_LINE}\"%F{green})%f %B\${MODULE}:%b \${1}\"
}

case \${ACTION} in
  install)
    if ERR=\$(command git clone \${REV:+-b} \${REV} -q --config core.autocrlf=false --recursive \${URL} \${DIR} 2>&1); then
      print_okay Installed
    else
      print_error 'Error during git clone' \${ERR}
      return 1
    fi
    ;;
  update)
    if ! builtin cd -q \${DIR} 2>/dev/null; then
      print_error \"Error during cd \${DIR}\"
      return 1
    fi
    if [[ \${PWD:A} != \${\$(command git rev-parse --show-toplevel 2>/dev/null):A} ]]; then
      print_error \"Module was not installed using git. Will not try to update. You can disable this with the zmodule option -z|--frozen.\"
      return 1
    fi
    if [[ \${URL} != \$(command git config --get remote.origin.url) ]]; then
      print_error \"URL does not match. Expected \${URL}. Will not try to update.\"
      return 1
    fi
    if ! ERR=\$(command git fetch -pq origin 2>&1); then
      print_error 'Error during git fetch' \${ERR}
      return 1
    fi
    if [[ \${TYPE} == tag ]]; then
      if [[ \${REV} == \$(command git describe --tags --exact-match 2>/dev/null) ]]; then
        print_okay 'Already up to date'
        return 0
      fi
    elif [[ -z \${REV} ]]; then
      # Get HEAD remote branch
      if ! ERR=\$(command git remote set-head origin -a 2>&1); then
        print_error 'Error during git remote set-head' \${ERR}
        return 1
      fi
      REV=\${\$(command git symbolic-ref --short refs/remotes/origin/HEAD)#origin/} || return 1
    fi
    if [[ \${TYPE} == branch ]]; then
      LOG_REV=\${REV}@{u}
    else
      LOG_REV=\${REV}
    fi
    LOG=\$(command git log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..\${LOG_REV} -- 2>/dev/null)
    if ! ERR=\$(command git checkout -q \${REV} -- 2>&1); then
      print_error 'Error during git checkout' \${ERR}
      return 1
    fi
    if [[ \${TYPE} == branch ]]; then
      if ! OUT=\$(command git merge --ff-only --no-progress -n 2>&1); then
        print_error 'Error during git merge' \${OUT}
        return 1
      fi
      # keep just first line of OUT
      OUT=\${OUT%%($'\n'|$'\r')*}
    else
      OUT=\"Updating to \${TYPE} \${REV}\"
    fi
    if ! ERR=\$(command git submodule update --init --recursive -q 2>&1); then
      print_error 'Error during git submodule update' \${ERR}
      return 1
    fi
    if (( PRINTLEVEL > 0 )); then
      if [[ -n \${LOG} ]] OUT=\${OUT}$'\n'\${(F):-  \${(f)^LOG}}
      print_okay \${OUT}
    fi
    ;;
esac
" ;;
    *)
      print -u2 -PR "${clear_line}%F{red}x %B${zmodule}:%b Unknown tool ${ztool}%f"
      return 1
      ;;
  esac
  zsh -c ${zcmd} ${ztool} "${@}" ${_zprintlevel}
}

zimfw() {
  local -r _zversion='1.5.1-SNAPSHOT' zusage="Usage: %B${0}%b <action> [%B-q%b|%B-v%b]

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
                  (prompts for confirmation)
  %Bupdate%b          Update current modules
  %Bupgrade%b         Upgrade zimfw
  %Bversion%b         Print zimfw version

Options:
  %B-q%b              Quiet (yes to prompts, and
                  only outputs errors and warnings)
  %B-v%b              Verbose"
  local -a _zdisableds _zmodules _zdirs _zfpaths _zfunctions _zcmds _zmodules_zargs
  local -i _zprintlevel=1
  if (( # > 2 )); then
     print -u2 -PR "%F{red}${0}: Too many options%f"$'\n\n'${zusage}
     return 2
  elif (( # > 1 )); then
    case ${2} in
      -q) _zprintlevel=0 ;;
      -v) _zprintlevel=2 ;;
      *)
        print -u2 -PR "%F{red}${0}: Unknown option ${2}%f"$'\n\n'${zusage}
        return 2
        ;;
    esac
  fi

  if ! zstyle -t ':zim' disable-version-check; then
    _zimfw_version_check
  fi

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
      _zimfw_source_zimrc ${1} || return 1
      autoload -Uz zargs && \
          zargs -n 7 -P 10 -- "${_zmodules_zargs[@]}" -- _zimfw_run_tool && \
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
      return 2
      ;;
  esac
}

zimfw "${@}"

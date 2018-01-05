#
# Minimal² theme
# https://github.com/subnixr/minimal
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

function {
  # Global settings
  MNML_OK_COLOR="${MNML_OK_COLOR:-2}"
  MNML_ERR_COLOR="${MNML_ERR_COLOR:-1}"
  # ADDED FOR ZIMFW
  MNML_DIV_COLOR="${MNML_DIV_COLOR:-5}"

  MNML_USER_CHAR="${MNML_USER_CHAR:-λ}"
  MNML_INSERT_CHAR="${MNML_INSERT_CHAR:-›}"
  MNML_NORMAL_CHAR="${MNML_NORMAL_CHAR:-·}"

  [ -z "$MNML_PROMPT" ] && MNML_PROMPT=(mnml_ssh mnml_pyenv mnml_status mnml_keymap)
  [ -z "$MNML_RPROMPT" ] && MNML_RPROMPT=('mnml_cwd 2 0' mnml_git)
  [ -z "$MNML_INFOLN" ] && MNML_INFOLN=(mnml_err mnml_jobs mnml_uhp mnml_files)

  [ -z "$MNML_MAGICENTER" ] && MNML_MAGICENTER=(mnml_me_dirs mnml_me_ls mnml_me_git)
}

# Components
function mnml_status {
  local okc="${MNML_OK_COLOR}"
  local errc="${MNML_ERR_COLOR}"
  local uchar="${MNML_USER_CHAR}"

  local job_ansi="0"
  if [ -n "$(jobs | sed -n '$=')" ]; then
    job_ansi="4"
  fi

  local err_ansi="${MNML_OK_COLOR}"
  if [ "${MNML_LAST_ERR}" != "0" ]; then
    err_ansi="${MNML_ERR_COLOR}"
  fi

  echo -n "%{\e[$job_ansi;3${err_ansi}m%}%(!.#.$uchar)%{\e[0m%}"
}

function mnml_keymap {
  local kmstat="${MNML_INSERT_CHAR}"
  [ "$KEYMAP" = 'vicmd' ] && kmstat="${MNML_NORMAL_CHAR}"
  echo -n "${kmstat}"
}

function mnml_cwd {
  local segments="${1:-2}"
  local seg_len="${2:-0}"

  local _w="%{\e[0m%}"
  local _g="%{\e[38;5;244m%}"

  if [ "${segments}" -le 0 ]; then
    segments=1
  fi
  if [ "${seg_len}" -gt 0 ] && [ "${seg_len}" -lt 4 ]; then
    seg_len=4
  fi
  local seg_hlen=$((seg_len / 2 - 1))

  local cwd="%${segments}~"
  cwd="${(%)cwd}"
  cwd=("${(@s:/:)cwd}")

  local pi=""
  for i in {1..${#cwd}}; do
    pi="$cwd[$i]"
    if [ "${seg_len}" -gt 0 ] && [ "${#pi}" -gt "${seg_len}" ]; then
      cwd[$i]="${pi:0:$seg_hlen}$_w..$_g${pi: -$seg_hlen}"
    fi
  done

  echo -n "$_g${(j:/:)cwd//\//$_w/$_g}$_w"
}

function mnml_git {
  # git
  if [[ -n ${git_info} ]]; then
    echo -n " ${(e)git_info[color]}${(e)git_info[prompt]}%{\e[0m%}"
  fi
}

function mnml_uhp {
  local _w="%{\e[0m%}"
  local _g="%{\e[38;5;244m%}"
  local cwd="%~"
  cwd="${(%)cwd}"

  echo -n "$_g%n$_w@$_g%m$_w:$_g${cwd//\//$_w/$_g}$_w"
}

function mnml_ssh {
  if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
    echo -n "$(hostname -s)"
  fi
}

function mnml_pyenv {
  if [ -n "${VIRTUAL_ENV}" ]; then
    _venv="$(basename ${VIRTUAL_ENV})"
    echo -n "${_venv%%.*}"
  fi
}

function mnml_err {
  local _w="%{\e[0m%}"
  local _err="%{\e[3${MNML_ERR_COLOR}m%}"

  if [ "${MNML_LAST_ERR:-0}" != "0" ]; then
    echo -n "${_err}${MNML_LAST_ERR}${_w}"
  fi
}

function mnml_jobs {
  local _w="%{\e[0m%}"
  local _g="%{\e[38;5;244m%}"

  local job_n="$(jobs | sed -n '$=')"
  if [ "${job_n}" -gt 0 ]; then
    echo -n "${_g}${job_n}${_w}&"
  fi
}

function mnml_files {
  local _w="%{\e[0m%}"
  local _g="%{\e[38;5;244m%}"

  local a_files="$(ls -1A | sed -n '$=')"
  local v_files="$(ls -1 | sed -n '$=')"
  local h_files="$((a_files - v_files))"

  local output="${_w}[${_g}${v_files:-0}"
  if [ "${h_files:-0}" -gt 0 ]; then
    output="$output $_w(${_g}$h_files${_w})"
  fi
  output="${output}${_w}]"

  echo -n "${output}"
}

# Magic enter functions
function mnml_me_dirs {
  local _w="\e[0m"
  local _g="\e[38;5;244m"

  if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
    local stack="$(dirs)"
    echo "${_g}${stack//\//${_w}/${_g}}${_w}"
  fi
}

function mnml_me_ls {
  if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
    COLUMNS=${COLUMNS} CLICOLOR_FORCE=1 ls -C -G -F
  else
    ls -C -F --color="always" -w ${COLUMNS}
  fi
}

function mnml_me_git {
  git -c color.status=always status -sb 2> /dev/null
}

# Wrappers & utils
# join outpus of components
function mnml_wrap {
  local arr=()
  local cmd_out=""
  for cmd in ${(P)1}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      arr+="${cmd_out}"
    fi
  done

  echo -n "${(j: :)arr}"
}

# expand string as prompt would do
function mnml_iline {
  echo "${(%)1}"
}

# display magic enter
function mnml_me {
  local output=()
  local cmd_output=""
  for cmd in ${MNML_MAGICENTER}; do
    cmd_out="$(eval "$cmd")"
    if [ -n "${cmd_out}" ]; then
      output+="${cmd_out}"
    fi
  done
  echo -n "${(j:\n:)output}" | less -XFR
}

# capture exit status and reset prompt
function mnml_line_init {
  MNML_LAST_ERR="$?" # I need to capture this ASAP
  zle reset-prompt
}

# redraw prompt on keymap select
function mnml_keymap_select {
  zle reset-prompt
}

# draw infoline if no command is given
function mnml_buffer_empty {
  if [ -z "${BUFFER}" ]; then
    mnml_iline "$(mnml_wrap MNML_INFOLN)"
    mnml_me
    zle redisplay
  else
    zle accept-line
  fi
}

prompt_minimal2_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_minimal2_setup() {
  # Setup
  autoload -Uz colors && colors
  autoload -Uz add-zsh-hook

  prompt_opts=(cr percent sp subst)

  zle -N zle-line-init mnml_line_init
  zle -N zle-keymap-select mnml_keymap_select
  zle -N buffer-empty mnml_buffer_empty

  add-zsh-hook precmd prompt_minimal2_precmd

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:dirty' format '%{\e[0;3${MNML_ERR_COLOR}m%}'
  zstyle ':zim:git-info:diverged' format '%{\e[0;3${MNML_DIV_COLOR}m%}'
  zstyle ':zim:git-info:behind' format '%{\e[0;3${MNML_DIV_COLOR}m%}↓ '
  zstyle ':zim:git-info:ahead' format '%{\e[0;3${MNML_DIV_COLOR}m%}↑ '
  zstyle ':zim:git-info:keys' format \
    'prompt' '%b%c' \
    'color' '$(coalesce "%D" "%V" "%B" "%A" "%{\e[0;3${MNML_OK_COLOR}m%}")'

  PROMPT='$(mnml_wrap MNML_PROMPT) '
  RPROMPT='$(mnml_wrap MNML_RPROMPT)'

  bindkey -M main "^M" buffer-empty
  bindkey -M vicmd "^M" buffer-empty
}

prompt_minimal2_setup "$@"
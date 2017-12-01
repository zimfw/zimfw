#
# Minimal² theme
# https://github.com/subnixr/minimal
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

function {
    # Switches
    MINIMAL_PROMPT="${MINIMAL_PROMPT:-yes}"
    MINIMAL_RPROMPT="${MINIMAL_RPROMPT:-yes}"
    MINIMAL_MAGIC_ENTER="${MINIMAL_MAGIC_ENTER:-yes}"
    MINIMAL_SSH_HOSTNAME="${MINIMAL_SSH_HOSTNAME:-yes}"

    # Parameters
    MINIMAL_OK_COLOR="${MINIMAL_OK_COLOR:-2}"
    MINIMAL_USER_CHAR="${MINIMAL_USER_CHAR:-λ}"
    MINIMAL_INSERT_CHAR="${MINIMAL_INSERT_CHAR:-›}"
    MINIMAL_NORMAL_CHAR="${MINIMAL_NORMAL_CHAR:-·}"
    MINIMAL_PWD_LEN="${MINIMAL_PWD_LEN:-2}"
    MINIMAL_PWD_CHAR_LEN="${MINIMAL_PWD_CHAR_LEN:-10}"
    MINIMAL_MAGIC_ENTER_MARGIN="${MINIMAL_MAGIC_ENTER_MARGIN:-  | }"
}

# Extensions
function prompt_minimal2_magic_output {
    prompt_minimal2_magic_output_base
}

function prompt_minimal2_vcs {
    # git
    if [[ -n ${git_info} ]]; then
        echo -n " ${(e)git_info[color]}${(e)git_info[prompt]}%{\e[0m%}"
    fi
}

function prompt_minimal2_env {
    # python virtual env
    if [ -n "$VIRTUAL_ENV" ]; then
        _venv="$(basename $VIRTUAL_ENV)"
        echo -n "${_venv%%.*} "
    fi
}

function prompt_minimal2_ssh_hostname {
    if [[ "${MINIMAL_SSH_HOSTNAME}" == "yes" ]] && ([[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]); then
        echo -n "$(hostname -s) "
    fi
}

# Left Prompt
function prompt_minimal2_lprompt {
    local user_status="%{\e[%(1j.4.0);3%(0?.$MINIMAL_OK_COLOR.1)m%}\
%(!.#.$MINIMAL_USER_CHAR)"
    local kmstatus="$MINIMAL_INSERT_CHAR"
    [ "$KEYMAP" = 'vicmd' ] && kmstatus="$MINIMAL_NORMAL_CHAR"

    echo -n "$user_status%{\e[0m%} $kmstatus"
}

function prompt_minimal2_ps2 {
    local kmstatus="$MINIMAL_INSERT_CHAR"
    local offset="$((${#_venv} + 2))"
    [ "$KEYMAP" = 'vicmd' ] && kmstatus="$MINIMAL_NORMAL_CHAR"

    printf " %.0s" {1..$offset}
    echo -n "$kmstatus"
}

# Right Prompt
function prompt_minimal2_path {
    local w="%{\e[0m%}"
    local cwd="%${MINIMAL_PWD_LEN}~"
    local pi=""
    local len="$MINIMAL_PWD_CHAR_LEN"
    [ "$len" -lt 4 ] && len=4
    local hlen=$((len / 2 - 1))
    cwd="${(%)cwd}"
    cwd=("${(@s:/:)cwd}")

    for i in {1..${#cwd}}; do
        pi="$cwd[$i]"
        [ "${#pi}" -gt "$len" ] && cwd[$i]="${pi:0:$hlen}$w..$_greyp${pi: -$hlen}"
    done

    echo -n "$_greyp${(j:/:)cwd//\//$w/$_greyp}$w"
}

# Magic Enter
function prompt_minimal2_infoline {
        local last_err="$1"
        local w="\e[0m"
        local rn="\e[0;31m"
        local rb="\e[1;31m"

        local user_host_pwd="$_grey%n$w@$_grey%m$w:$_grey%~$w"
        user_host_pwd="${${(%)user_host_pwd}//\//$w/$_grey}"

        local v_files="$(ls -1 | sed -n '$=')"
        local h_files="$(ls -1A | sed -n '$=')"

        local job_n="$(jobs | sed -n '$=')"

        local iline="[$user_host_pwd] [$_grey${v_files:-0}$w ($_grey${h_files:-0}$w)]"
        [ "$job_n" -gt 0 ] && iline="$iline [$_grey$job_n$w&]"

        if [ "$last_err" != "0" ]; then
                iline="$iline \e[1;31m[\e[0;31m$last_err\e[1;31m]$w"
        fi

        echo "$iline"
}

function prompt_minimal2_magic_output_base {
    local margin="${#MINIMAL_MAGIC_ENTER_MARGIN}"

    if [ "$(dirs -p | wc -l)" -gt 1 ]; then
        local stack="$(dirs)"
        echo "[${_grey}dirs\e[0m - ${_grey}${stack//\//\e[0m/$_grey}\e[0m]"
    fi

    if [ "$(uname)" = "Darwin" ] && ! ls --version &> /dev/null; then
        COLUMNS=$((COLUMNS - margin)) CLICOLOR_FORCE=1 ls -C -G
    else
        ls -C --color="always" -w $((COLUMNS - margin))
    fi

    git -c color.status=always status -sb 2> /dev/null
}

function prompt_minimal2_wrap_output {
    local output="$1"
    local output_len="$(echo "$output" | sed -n '$=')"
    if [ -n "$output" ]; then
        if [ "$output_len" -gt "$((LINES - 2))" -a -n "$PAGER" ]; then
            printf "$output\n" | "$PAGER" -R
        else
            printf "$output\n" | sed "s/^/$MINIMAL_MAGIC_ENTER_MARGIN/"
        fi
    fi
}

function prompt_minimal2_magic_enter {
    local last_err="$?" # I need to capture this ASAP

    if [ -z "$BUFFER" ]; then
        prompt_minimal2_infoline $last_err
        prompt_minimal2_wrap_output "$(prompt_minimal2_magic_output)"
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

    _grey="\e[38;5;244m"
    _greyp="%{$_grey%}"

    # Apply Switches
    if [ "$MINIMAL_PROMPT" = "yes" ]; then
        # prompt redraw on vimode change
        function reset_prompt {
            zle reset-prompt
        }

        prompt_opts=(cr percent sp subst)

        zle -N zle-line-init reset_prompt
        zle -N zle-keymap-select reset_prompt

        add-zsh-hook precmd prompt_minimal2_precmd

        zstyle ':zim:git-info:branch' format '%b'
        zstyle ':zim:git-info:commit' format '%c'
        zstyle ':zim:git-info:dirty' format '%{\e[0;31m%}'
        zstyle ':zim:git-info:diverged' format '%{\e[0;31m%}'
        zstyle ':zim:git-info:behind' format '%F{11}'
        zstyle ':zim:git-info:ahead' format '%f'
        zstyle ':zim:git-info:keys' format \
            'prompt' '%b%c' \
            'color' '$(coalesce "%D" "%V" "%B" "%A" "%{\e[0;3${MINIMAL_OK_COLOR}m%}")'

        PROMPT='$(prompt_minimal2_env)$(prompt_minimal2_ssh_hostname)$(prompt_minimal2_lprompt) '
        PS2='$(prompt_minimal2_ps2) '
        [ "$MINIMAL_RPROMPT" = "yes" ] && RPROMPT='$(prompt_minimal2_path)$(prompt_minimal2_vcs)'
    fi

    if [ "$MINIMAL_MAGIC_ENTER" = "yes" ]; then
        zle -N prompt_minimal2-magic-enter prompt_minimal2_magic_enter
        bindkey -M main  "^M" prompt_minimal2-magic-enter
        bindkey -M vicmd "^M" prompt_minimal2-magic-enter
    fi
}

prompt_minimal2_setup "$@"
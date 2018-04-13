#
# Editor and input char assignment
#


# Return if requirements are not found.
if [[ ${TERM} == 'dumb' ]]; then
  return 1
fi

# Use human-friendly identifiers.
zmodload zsh/terminfo
typeset -gA key_info
key_info=(
  'Control'      '\C-'
  'ControlLeft'  '\e[1;5D \e[5D \e\e[D \eOd \eOD'
  'ControlRight' '\e[1;5C \e[5C \e\e[C \eOc \eOC'
  'Escape'       '\e'
  'Meta'         '\M-'
  'Backspace'    "^?"
  'Delete'       "^[[3~"
  'F1'           "${terminfo[kf1]}"
  'F2'           "${terminfo[kf2]}"
  'F3'           "${terminfo[kf3]}"
  'F4'           "${terminfo[kf4]}"
  'F5'           "${terminfo[kf5]}"
  'F6'           "${terminfo[kf6]}"
  'F7'           "${terminfo[kf7]}"
  'F8'           "${terminfo[kf8]}"
  'F9'           "${terminfo[kf9]}"
  'F10'          "${terminfo[kf10]}"
  'F11'          "${terminfo[kf11]}"
  'F12'          "${terminfo[kf12]}"
  'Insert'       "${terminfo[kich1]}"
  'Home'         "${terminfo[khome]}"
  'PageUp'       "${terminfo[kpp]}"
  'End'          "${terminfo[kend]}"
  'PageDown'     "${terminfo[knp]}"
  'Up'           "${terminfo[kcuu1]}"
  'Left'         "${terminfo[kcub1]}"
  'Down'         "${terminfo[kcud1]}"
  'Right'        "${terminfo[kcuf1]}"
  'BackTab'      "${terminfo[kcbt]}"
)

# Bind the keys

local key
for key in "${(s: :)key_info[ControlLeft]}"; do
  bindkey ${key} backward-word
done
for key in "${(s: :)key_info[ControlRight]}"; do
  bindkey ${key} forward-word
done

if [[ -n "${key_info[Home]}" ]]; then
  bindkey "${key_info[Home]}" beginning-of-line
fi

if [[ -n "${key_info[End]}" ]]; then
  bindkey "${key_info[End]}" end-of-line
fi

if [[ -n "${key_info[PageUp]}" ]]; then
  bindkey "${key_info[PageUp]}" up-line-or-history
fi

if [[ -n "${key_info[PageDown]}" ]]; then
  bindkey "${key_info[PageDown]}" down-line-or-history
fi

if [[ -n "${key_info[Insert]}" ]]; then
  bindkey "${key_info[Insert]}" overwrite-mode
fi

if [[ ${zdouble_dot_expand} == "true" ]]; then
  double-dot-expand() {
    if [[ ${LBUFFER} == *.. ]]; then
      LBUFFER+='/..'
    else
      LBUFFER+='.'
    fi
  }
  zle -N double-dot-expand
  bindkey "." double-dot-expand
fi

bindkey "${key_info[Delete]}" delete-char
bindkey "${key_info[Backspace]}" backward-delete-char

bindkey "${key_info[Left]}" backward-char
bindkey "${key_info[Right]}" forward-char

# Expandpace.
bindkey ' ' magic-space

# Clear
bindkey "${key_info[Control]}L" clear-screen

# Bind Shift + Tab to go to the previous menu item.
if [[ -n "${key_info[BackTab]}" ]]; then
  bindkey "${key_info[BackTab]}" reverse-menu-complete
fi

autoload -Uz is-at-least && if ! is-at-least 5.3; then
  # Redisplay after completing, and avoid blank prompt after <Tab><Tab><Ctrl-C>
  expand-or-complete-with-redisplay() {
    print -Pn '...'
    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-redisplay
  bindkey "${key_info[Control]}I" expand-or-complete-with-redisplay
fi

# Put into application mode and validate ${terminfo}
zle-line-init() {
  if (( ${+terminfo[smkx]} )); then
    echoti smkx
  fi
}
zle-line-finish() {
  if (( ${+terminfo[rmkx]} )); then
    echoti rmkx
  fi
}
zle -N zle-line-init
zle -N zle-line-finish

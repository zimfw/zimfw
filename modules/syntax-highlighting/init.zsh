#
# enables fish-shell like syntax highlighting
#

source "${0:h}/external/zsh-syntax-highlighting.zsh" || return 1

# highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(${zhighlighters[@]})

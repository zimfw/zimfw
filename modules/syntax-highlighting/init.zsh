#
# enables fish-shell like syntax highlighting
#

# highlighters
ZSH_HIGHLIGHT_HIGHLIGHTERS=(${zhighlighters[@]})

source "${0:h}/external/zsh-syntax-highlighting.zsh" || return 1

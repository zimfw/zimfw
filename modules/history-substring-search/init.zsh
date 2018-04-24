#
# Enable searching history with substrings
#

# Source script
source ${0:h}/external/zsh-history-substring-search.zsh || return 1

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down

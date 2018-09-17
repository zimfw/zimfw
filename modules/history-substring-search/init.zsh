#
# Enable searching history with substrings
#

# Source script
source ${0:h}/external/zsh-history-substring-search.zsh || return 1

# Binding ^[[A/^[[B manually mean up/down works with history-substring-search both before and after zle-line-init
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Bind up and down keys
zmodload -F zsh/terminfo +p:terminfo
bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down

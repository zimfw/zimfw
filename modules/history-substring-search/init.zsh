#
# enables searching history with substrings
#

# source script
source ${0:h}/external/zsh-history-substring-search.zsh || return 1

# bind UP and DOWN keys
bindkey "${terminfo[kcuu1]}" history-substring-search-up
bindkey "${terminfo[kcud1]}" history-substring-search-down

# bind UP and DOWN arrow keys (compatibility fallback)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

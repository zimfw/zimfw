#
# Archive aliases
#

# if pigz/pbzip2 are available, alias them as they are drop-in replacements for gzip and bzip2, respectively.

#
# pigz
#

if (( $+commands[pigz] )); then
  alias gzip='pigz'
fi

if (( $+commands[unpigz] )); then
  alias gunzip='pigz'
fi

#
# pbzip2
#

if (( $+commands[pbzip2] )); then
  alias bzip2='pbzip2'
fi

if (( $+commands[pbunzip2] )); then
  alias bunzip2='pbzip2'
fi

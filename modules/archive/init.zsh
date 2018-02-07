#
# Archive aliases
#

# if pigz/pbzip2 are available, alias them as they are drop-in replacements for gzip and bzip2, respectively.

#
# pigz
#
(( ${+commands[pigz]} )) && alias gzip='pigz'
(( ${+commands[unpigz]} )) && alias gunzip='unpigz'

#
# pbzip2
#
(( ${+commands[pbzip2]} )) && alias bzip2='pbzip2'
(( ${+commands[pbunzip2]} )) && alias bunzip2='pbunzip2'

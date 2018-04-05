#
# load user-defined prompt
#

if [[ ! ${TERM} == (linux|*bsd*|dumb) ]] && (( ${+zprompt_theme} )); then
  autoload -Uz promptinit && promptinit
  prompt ${(ps: :)${zprompt_theme}}
fi

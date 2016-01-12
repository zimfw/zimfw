#
# Provides for easier use of 256 colors and effects.
#

# Return if requirements are not found.
if [[ ${TERM} == 'dumb' ]]; then
  return 1
elif
  [[ -n ${FX} ]]; then
  # FX is set or sourced by another module
  return 1
fi

typeset -gA FX FG BG

FX=(
                                        reset                        "\e[00m"
                                        normal                       "\e[22m"
  bold                      "\e[01m"    no-bold                      "\e[22m"
  italic                    "\e[03m"    no-italic                    "\e[23m"
  underline                 "\e[04m"    no-underline                 "\e[24m"
  blink                     "\e[05m"    no-blink                     "\e[25m"
  reverse                   "\e[07m"    no-reverse                   "\e[27m"
)

FG[none]="${FX[none]}"
BG[none]="${FX[none]}"
colors=(black red green yellow blue magenta cyan white)
for color in {0..255}; do
  if (( ${color} >= 0 )) && (( ${color} < ${#colors} )); then
    index=$(( ${color} + 1 ))
    FG[${colors[${index}]}]="\e[38;5;${color}m"
    BG[${colors[${index}]}]="\e[48;5;${color}m"
  fi

  FG[${color}]="\e[38;5;${color}m"
  BG[${color}]="\e[48;5;${color}m"
done
unset color{s,} index

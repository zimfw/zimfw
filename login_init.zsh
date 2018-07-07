#
# startup file read in interactive login shells
#
# The following code helps us by optimizing the existing framework.
# This includes zcompile, zcompdump, etc.
#

zcompare() {
    if [[ -s ${1} && ( ! -s ${1}.zwc || ${1} -nt ${1}.zwc) ]]; then
        zcompile ${1}
    fi
}

(
local dir file
setopt LOCAL_OPTIONS EXTENDED_GLOB
autoload -U zrecompile
# zcompile the completion cache; siginificant speedup
zcompare ${ZDOTDIR:-${HOME}}/${zcompdump_file:-.zcompdump}

# zcompile .zshrc
zcompare ${ZDOTDIR:-${HOME}}/.zshrc

# zcompile enabled module autoloaded functions
for dir in ${ZIM_HOME}/modules/${^zmodules}/functions(/FN); do
    zrecompile -pq ${dir}.zwc ${dir}/^(_*|prompt_*_setup|*.*)(-.N)
done

# zcompile enabled module scripts
for file in ${ZIM_HOME}/modules/${^zmodules}/(^*test*/)#*.zsh{,-theme}(.NLk+1); do
    zcompare ${file}
done

# zcompile all prompt setup scripts
for file in ${ZIM_HOME}/modules/prompt/functions/prompt_*_setup; do
    zcompare ${file}
done
) &!

print "Zim commit ref: $(builtin cd ${ZIM_HOME} && command git rev-parse --short HEAD)"
print "Zsh version:    ${ZSH_VERSION}"
print "System info:    $(command uname -a)"

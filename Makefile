srcfiles := src/zimfw.zsh.erb $(wildcard src/*/*.erb)

zimfw.zsh: $(srcfiles)
	erb $< >| $@

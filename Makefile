srcfiles := src/zimfw.zsh.erb $(wildcard src/*/*.erb) LICENSE

zimfw.zsh: $(srcfiles)
	erb $< >| $@

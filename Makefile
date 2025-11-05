srcfiles := src/zimfw.zsh.erb $(wildcard src/*/*.erb src/templates/*) LICENSE

zimfw.zsh: $(srcfiles)
	erb $< >| $@

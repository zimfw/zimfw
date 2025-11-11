.PHONY: test

srcfiles := src/zimfw.zsh.erb $(wildcard src/*/*.erb src/templates/*) LICENSE

zimfw.zsh: $(srcfiles)
	erb $< >| $@

test:
	@test/bats/bin/bats test/test_*.bats

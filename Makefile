.PHONY: lint test

srcfiles := src/zimfw.zsh.erb $(wildcard src/*/*.erb src/templates/*) LICENSE
testfiles := $(wildcard test/test_*.bats)

zimfw.zsh: $(srcfiles)
	erb $< >| $@

lint:
	@shellcheck $(testfiles) test/test_helper/bin/curl test/test_helper/setup_all

test: zimfw.zsh lint
	@if [[ -x test/bats/bin/bats ]]; then \
		test/bats/bin/bats $(testfiles); \
	else \
		bats $(testfiles); \
	fi

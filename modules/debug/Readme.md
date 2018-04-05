Debug
=====

Provides a function to debug Zim.

Functions
---------

  - `trace-zim` provides a trace of Zsh/Zim startup

Notes
-----

The `trace-zim` command will not alter your current dotfiles.
It will copy your environment to a temporary directory, launch zsh
within that environment, and output logs.

This will provide a ztrace.tar.gz archive, which should be attached
to any bug reports if you need help with an issue that you don't understand.

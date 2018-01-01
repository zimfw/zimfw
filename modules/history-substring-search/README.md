History-Substring-Search
========================

Allows for fish shell-like searching of history with UP and DOWN.

![example][fish_shell]

This module requires the [input](https://github.com/zimfw/zimfw/blob/master/modules/input/README.md) module. Without it, you may experience odd behavior.
Put 'input' in the first line and 'history-substring-search' on the second line of `zmodules` in your `.zimrc`.

Additionally, if you use [syntax-highlighting](https://github.com/zimfw/zimfw/blob/master/modules/syntax-highlighting/README.md), place 'syntax-highlighting' before 'history-substring-search' on the second line of `zmodules` in your `.zimrc`.

The options set explicitly by init.zsh are the default options, and are only set for consistancy.

Functionality is sourced from [history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)

Contributing
------------

Contributions should be submitted [upstream to history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)

[fish_shell]: https://i.eriner.me/zim_history-substring-search.gif

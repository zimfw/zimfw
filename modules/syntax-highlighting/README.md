Syntax-Highlighting
===================

Adds fish shell-like [syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) to your shell.

![syntax-highlighting][syntax_highlighting]

If you are also using [history-substring-search](https://github.com/zimfw/zimfw/blob/master/modules/history-substring-search/README.md), 
ensure you have placed 'syntax-highlighting' before 'history-substring-search' on the second line of `zmodules` in your `.zimrc`.

.zimrc Configuration
--------------------

  * `zhighlighters=(main brackets cursor)` add any highlighters you want as described [here](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md#zsh-syntax-highlighting--highlighters).

Contributing
------------

Contributions should be submitted [upstream to zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)

[syntax_highlighting]: https://i.eriner.me/zim_syntax-highlighting.gif

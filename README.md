ZIM - Zsh IMproved
==================

<div align="center">
  <a href="https://github.com/zimfw/zimfw">
    <img width=650px src="https://i.eriner.me/zim_banner.png">
  </a>
</div>

What is Zim?
------------
Zim is a Zsh configuration framework with [blazing speed][speed] and modular extensions.

Zim is very easy to customize, and comes with a rich set of modules and features without compromising on speed or functionality!

What does Zim offer?
-----------------
If you're here, it means you want to see the cool shit Zim can do. Check out the [available modules][modules]!

Below is a brief showcase of Zim's features.

### Speed
For a speed comparison between Zim and other frameworks, see [this wiki entry][speed].

### Themes

To preview some of the available themes, check the [themes wiki page][themes].

### Fish-shell History Navigation
![history-substring-search][fish_shell]

### Syntax Highlighting
![syntax-highlighting][syntax_highlighting]

### And much more!
Zim has many modules! Enable as many or as few as you'd like.

Installation
------------
Installing Zim is easy. If you have a different shell framework installed (like oh-my-zsh or prezto),
*uninstall those first to prevent conflicts*. It can be installed manually by following the instructions below:

1. In a Zsh shell, clone the repository:
  ```
  git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim
  ```

2. Paste this into your terminal to prepend the initialization templates to your configs:
  ```
  for template_file in ${ZDOTDIR:-${HOME}}/.zim/templates/*; do
    user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
    cat ${template_file} ${user_file}(.N) >! ${user_file}
  done
  ```

3. Set Zsh as the default shell:
  ```
  chsh -s =zsh
  ```

4. Open a new terminal and finish optimization (this is only needed once, hereafter it will happen upon desktop/tty login):
  ```
  source ${ZDOTDIR:-${HOME}}/.zlogin
  ```

5. You're done! Enjoy your Zsh IMproved! Take some time to read about the [available modules][modules] and tweak your `.zshrc` file.

Updating
--------

To update zim, run:

```
zmanage update
```

For more information about the `zmanage` tool, run `zmanage help`.

Uninstalling
------------

The best way to remove zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshrc`.

However, there are some **experimental** convenience functions to remove zim:

**NOTE: This functionality is experimental!**

To remove zim, run:
```
zmanage remove
```

**NOTE: This functionality is experimental!**


[fish_shell]: https://i.eriner.me/zim_history-substring-search.gif
[syntax_highlighting]: https://i.eriner.me/zim_syntax-highlighting.gif
[speed]: https://github.com/zimfw/zimfw/wiki/Speed
[modules]: https://github.com/zimfw/zimfw/wiki/Modules
[themes]: https://github.com/zimfw/zimfw/wiki/Themes

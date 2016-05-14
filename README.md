ZIM - Zsh IMproved
==================

<div align="center">
  <a href="https://github.com/Eriner/zim">
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
uninstall those first to prevent conflicts. Arch users can install 
[zsh-zim-git](https://aur.archlinux.org/packages/zsh-zim-git/) from the AUR. It can be installed manually
by following the instructions below:

1. In a Zsh shell, clone the repository:
  ```
  git clone --recursive https://github.com/Eriner/zim.git ${ZDOTDIR:-${HOME}}/.zim
  ```

2. Paste this into your terminal to prepend the initialization templates to your configs:
  ```
  setopt EXTENDED_GLOB
  for template_file ( ${ZDOTDIR:-${HOME}}/.zim/templates/* ); do
    user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
    touch ${user_file}
    ( print -rn "$(<${template_file})$(<${user_file})" >! ${user_file} ) 2>/dev/null
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

[fish_shell]: https://i.eriner.me/zim_history-substring-search.gif
[syntax_highlighting]: https://i.eriner.me/zim_syntax-highlighting.gif
[speed]: https://github.com/Eriner/zim/wiki/Speed
[modules]: https://github.com/Eriner/zim/wiki/Modules
[themes]: https://github.com/Eriner/zim/wiki/Themes

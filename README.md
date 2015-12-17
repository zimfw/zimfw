ZIM - Zsh IMproved
==================

<div align="center">
  <a href="http://github.com/Eriner/zim">
    <img width=650px src="http://i.eriner.me/zim_banner.png">
  </a>
</div>

What is Zim?
------------
Zim is a Zsh configuration fromework with blazing speed and modular extensions.

Zim is very easy to customize and add your own functionality. But worry not! You don't *have* to if that's not your cup of tea!

Zim comes with a rich set of default modules and features without comprimising on speed or functionality!

What does Zim offer?
-----------------
If you're here, it means you want to see the cool shit Zim can do. Check out the [available modules](https://github.com/Eriner/zim/wiki/Modules)!

Below is a brief showcase of Zim's features.

#### Themes
![Eriner Theme][theme_eriner]

#### Fish-shell History Navigation
![history-substring-search][fish_shell]

#### Syntax Highlighting
![syntax-highlighting][syntax_highlighting]

#### Speed
For a speed comparison between zim and prezto, see [this gist][zim_vs_prezto]

#### And much more!
Zim has many modules! Enable as many or as few as you'd like.

Installation
------------
Installing Zim is easy. If you have a different shell framework installed (like oh-my-zsh or prezto),
uninstall those first to prevent conflicts.

1. In Zsh, clone the repository:
  ```
  git clone --recursive https://github.com/Eriner/zim.git ${ZDOTDIR:-$HOME}/.zim
  ```

2. Copy the template configuration files (or append to existing configs):
  ```
  setopt EXTENDED_GLOB
  for template_file ( ${ZDOTDIR:-$HOME}/.zim/templates/* ); do
    cat ${template_file} | tee -a ${ZDOTDIR:-$HOME}/.$(basename ${template_file}) > /dev/null
  done
  ```

3. Set Zsh as the default shell:
  ```
  chsh -s $(which zsh)
  ```

4. Open a new terminal and admire your work!

[theme_eriner]: http://i.eriner.me/eriner_prompt_theme.png
[fish_shell]: http://i.eriner.me/zim_history-substring-search.gif
[syntax_highlighting]: http://i.eriner.me/zim_syntax-highlighting.gif
[zim_vs_prezto]: https://gist.github.com/Eriner/3aa88b161615c2913930

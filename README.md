ZIM - Zsh IMproved
==================
Moving to Zsh because you heard it was cool? Tried other frameworks but found them slow?
Want something that works without spending hours configuring sane settings? Want to be the conqueror of shells?

Meet Zim.

What is Zim?
------------
Zim is a Zsh configuration fromework that prides itself on speed and modularity.
Zim is very easy to customize and add your own functionality. But worry not! You don't *have* to if that's not your cup of tea!

Zim comes with a rich set of default modules and features without comprimising on speed or functionality!

What does Zim offer?
-----------------
If you're here, it means you want to see the cool shit Zim has to offer.

#### Themes
> Images of cascading themes

#### Fish-shell History Navigation
> GIF OF history-substring-search

#### Syntax Highlighting
> GIF of syntax highlighting

#### Speed
> possible side-by-side comparison of oh-my-zsh/zprezto/zim

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

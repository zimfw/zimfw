Zsh IMproved FrameWork
======================

<div align="center">
  <a href="https://github.com/zimfw/zimfw">
    <img width="650" src="https://zimfw.github.io/images/zim_banner.png">
  </a>
</div>

What is Zim?
------------
Zim is a Zsh configuration framework with [blazing speed] and modular extensions.

Zim is very easy to customize, and comes with a rich set of modules and features without compromising on speed or functionality!

What does Zim offer?
-----------------
If you're here, it means you want to see the cool shit Zim can do. Check out the [available modules]!

Below is a brief showcase of Zim's features.

### Speed
For a speed comparison between Zim and other frameworks, see [this wiki entry][blazing speed].

### Themes

To preview some of the available themes, check the [themes wiki page].

### Fish-shell history navigation
![history-substring-search]

### Syntax highlighting
![syntax-highlighting]

### And much more!
Zim has many modules! Enable as many or as few as you'd like.

Installation
------------
Installing Zim is easy:

  * With curl:

        curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

  * With wget:

        wget -nv -O - https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

Open a new terminal and you're done! Enjoy your Zsh IMproved! Take some time to
read about the [available modules] and tweak your `.zshrc` file.

If you have a different shell framework installed (like oh-my-zsh or prezto),
*uninstall those first to prevent conflicts*.

### Manual installation

1. Start a Zsh shell

       zsh

2. Set Zsh as the default shell:

       chsh -s =zsh

3. Copy https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh to
   `~/.zim/zimfw.zsh`.

4. Add the lines in the following templates to the respective dot files:
   * [~/.zshenv](https://github.com/zimfw/install/blob/master/src/templates/zshenv)
   * [~/.zshrc](https://github.com/zimfw/install/blob/master/src/templates/zshrc)
   * [~/.zlogin](https://github.com/zimfw/install/blob/master/src/templates/zlogin)
   * [~/.zimrc](https://github.com/zimfw/install/blob/master/src/templates/zimrc)

5. Install the modules defined in `~/.zimrc` and build the initialization scripts:

       source ~/.zim/zimfw.zsh install

Usage
-----

### zmodule

Add `zmodule` calls to your `~/.zimrc` file to define the modules to be initialized.
The modules are initialized in the same order they are defined. Add:

    zmodule <url> [-n|--name <module_name>] [options]

where `<url>` is the required repository URL or path. The following formats
are equivalent: `name`, `zimfw/name`, `https://github.com/zimfw/name.git`.

By default, the module name is the last component in the `<url>`. Use the
`-n|--name <module_name>` option to set a custom module name.

#### Repository options

* `-b|--branch <branch_name>`: Use specified branch when installing and
  updating the module. Overrides the tag option. Default: `master`.
* `-t|--tag <tag_name>`: Use specified tag when installing and updating the
  module. Overrides the branch option.
* `-z|--frozen`: Don't install or update the module.

#### Initialization options

* `-f|--fpath <path>`: Add specified path to `fpath`. The path is relative to
  the module root directory. Default: `functions`, if the subdirectory exists.
* `-a|--autoload <function_name>`: Autoload specified function. Default: all
  valid names inside the module's specified `fpath` paths.
* `-s|--source <file_path>`: Source specified file. The file path is relative
  to the module root directory. Default: the file with largest size matching
  `{init.zsh|module_name.{zsh|plugin.zsh|zsh-theme|sh}}`, if any exists.
* `-d|--disabled`: Don't use or uninstall the module.

### zimfw

Added new modules to `~/.zimrc`? Run:

    zimfw install

Removed modules from `~/.zimrc`? Run:

    zimfw uninstall

Want to update your modules to their latest revisions? Run:

    zimfw update

Want to upgrade `~/.zim/zimfw.zsh` to the latest version? Run:

    zimfw upgrade

For more information about the `zimfw` tool, run `zimfw` with no parameters.

Uninstalling
------------

The best way to remove Zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshenv`, `~/.zshrc` and `~/.zlogin`.

[history-substring-search]: https://zimfw.github.io/images/zim_history-substring-search.gif
[syntax-highlighting]: https://zimfw.github.io/images/zim_syntax-highlighting.gif
[blazing speed]: https://github.com/zimfw/zimfw/wiki/Speed
[available modules]: https://github.com/zimfw/zimfw/wiki/Modules
[themes wiki page]: https://github.com/zimfw/zimfw/wiki/Themes

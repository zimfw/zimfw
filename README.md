Zsh IMproved FrameWork
======================

<div align="center">
  <a href="https://github.com/zimfw/zimfw">
    <img width=650px src="https://zimfw.github.io/images/zim_banner.png">
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

        curl -fsSL https://raw.githubusercontent.com/zimfw/install/develop/install.zsh | zsh

  * With wget:

        wget -nv -O - https://raw.githubusercontent.com/zimfw/install/develop/install.zsh | zsh

Open a new terminal and you're done! Enjoy your Zsh IMproved! Take some time to
read about the [available modules] and tweak your `.zshrc` file.

If you have a different shell framework installed (like oh-my-zsh or prezto),
*uninstall those first to prevent conflicts*.

Usage
-----

### zmodule

Add `zmodule` calls to your `.zimrc` file to define the modules to be loaded.
The modules are loaded in the same order they are defined. Add:

    zmodule <url> [-n|--name <module_name>] [options]

where &lt;url&gt; is the required repository URL or path. The following formats
are equivalent: *name*, zimfw/*name*, https://<em></em>github.com/zimfw/<em>name</em>.git

By default, the module name is the last component in the &lt;url&gt;. Use the
`-n`|`--name` &lt;module&lowbar;name&gt; option to set a custom module name.

#### Repository options

* `-b`&vert;`--branch` &lt;branch&lowbar;name&gt;: Use specified branch when installing and updating the module. Overrides the tag option. Default: `master`
* `-t`&vert;`--tag` &lt;tag&lowbar;name&gt;: Use specified tag when installing and updating the module. Overrides the branch option.
* `-z`&vert;`--frozen`: Don't install or update the module

#### Startup options

* `-f`&vert;`--fpath` &lt;path&gt;: Add specified path to `fpath`. The path is relative to the module root directory. Default: `functions`, if the subdirectory exists
* `-a`&vert;`--autoload` &lt;function&lowbar;name&gt;: Autoload specified function. Default: all valid names inside all the module specified `fpath` paths
* `-s`&vert;`--source` &lt;file&lowbar;path&gt;: Source specified file. The file path is relative to the module root directory. Default: the file with largest size matching `{init.zsh|module_name.{zsh|plugin.zsh|zsh-theme|sh}}`, if any exists
* `-d`&vert;`--disabled`: Don't use or clean the module

### zimfw

To install new defined modules, run:

    zimfw install

To update your modules, run:

    zimfw update

To upgrade Zim, run:

    zimfw upgrade

For more information about the `zimfw` tool, run `zimfw` with no parameters.

Uninstalling
------------

The best way to remove Zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshrc` and `~/.zlogin`.

[history-substring-search]: https://zimfw.github.io/images/zim_history-substring-search.gif
[syntax-highlighting]: https://zimfw.github.io/images/zim_syntax-highlighting.gif
[blazing speed]: https://github.com/zimfw/zimfw/wiki/Speed
[available modules]: https://github.com/zimfw/zimfw/wiki/Modules
[themes wiki page]: https://github.com/zimfw/zimfw/wiki/Themes

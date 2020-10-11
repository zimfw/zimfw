<div align="center">
  <a href="https://github.com/zimfw/zimfw">
    <img width="650" src="https://zimfw.github.io/images/zim_banner.png">
  </a>
</div>

Zsh IMproved FrameWork
======================

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
read about the [available modules] and tweak your `~/.zshrc` file.

If you have a different shell framework installed (like oh-my-zsh or prezto),
*uninstall those first to prevent conflicts*.

### Manual installation

1. Set Zsh as the default shell:

       chsh -s $(which zsh)

2. Add the lines in the following templates to the respective dot files:
   * [~/.zshenv](https://github.com/zimfw/install/blob/master/src/templates/zshenv)
   * [~/.zshrc](https://github.com/zimfw/install/blob/master/src/templates/zshrc)
   * [~/.zlogin](https://github.com/zimfw/install/blob/master/src/templates/zlogin)
   * [~/.zimrc](https://github.com/zimfw/install/blob/master/src/templates/zimrc)

3. Copy https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh to
   `~/.zim/zimfw.zsh`.

4. Install the modules defined in `~/.zimrc` and build the initialization scripts:

       zsh ~/.zim/zimfw.zsh install

Usage
-----

### zmodule

<pre>
Usage: <strong>zmodule</strong> &lt;url&gt; [<strong>-n</strong>|<strong>--name</strong> &lt;module_name&gt;] [options]

Add <strong>zmodule</strong> calls to your <strong>~/.zimrc</strong> file to define the modules to be initialized. The modules are
initialized in the same order they are defined.

  &lt;url&gt;                      Module absolute path or repository URL. The following URL formats
                             are equivalent: <strong>name</strong>, <strong>zimfw/name</strong>, <strong>https://github.com/zimfw/name.git</strong>.
  <strong>-n</strong>|<strong>--name</strong> &lt;module_name&gt;    Set a custom module name. Default: the last component in the &lt;url&gt;.

Repository options:
  <strong>-b</strong>|<strong>--branch</strong> &lt;branch_name&gt;  Use specified branch when installing and updating the module.
                             Overrides the tag option. Default: <strong>master</strong>.
  <strong>-t</strong>|<strong>--tag</strong> &lt;tag_name&gt;        Use specified tag when installing and updating the module.
                             Overrides the branch option.
  <strong>-z</strong>|<strong>--frozen</strong>                Don't install or update the module.

Initialization options:
  <strong>-f</strong>|<strong>--fpath</strong> &lt;path&gt;          Add specified path to fpath. The path is relative to the module
                             root directory. Default: <strong>functions</strong>, if the subdirectory exists.
  <strong>-a</strong>|<strong>--autoload</strong> &lt;func_name&gt;  Autoload specified function. Default: all valid names inside the
                             module's specified fpath paths.
  <strong>-s</strong>|<strong>--source</strong> &lt;file_path&gt;    Source specified file. The file path is relative to the module root
                             directory. Default: the file with largest size matching
                             <strong>{init.zsh,module_name.{zsh,plugin.zsh,zsh-theme,sh}}</strong>, if any exist.
  <strong>-c</strong>|<strong>--cmd</strong> &lt;command&gt;         Execute specified command. Occurrences of the <strong>{}</strong> placeholder in the
                             command are substituted by the module root directory path.
                             <strong>-s 'script.zsh'</strong> and <strong>-c 'source {}/script.zsh'</strong> are equivalent.
  <strong>-d</strong>|<strong>--disabled</strong>              Don't initialize or uninstall the module.
</pre>

### zimfw

Added new modules to `~/.zimrc`? Run `zimfw install`.

Removed modules from `~/.zimrc`? Run `zimfw uninstall`.

Want to update your modules to their latest revisions? Run `zimfw update`.

Want to upgrade `zimfw` to its latest version? Run `zimfw upgrade`.

For more information about the `zimfw` tool, run `zimfw help`.

Settings
--------

By default, `zimfw` will check if it has a new version available every 30 days.
This can be disabled with:

    zstyle ':zim' disable-version-check yes

Uninstalling
------------

The best way to remove Zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshenv`, `~/.zshrc` and `~/.zlogin`.

[history-substring-search]: https://zimfw.github.io/images/zim_history-substring-search.gif
[syntax-highlighting]: https://zimfw.github.io/images/zim_syntax-highlighting.gif
[blazing speed]: https://github.com/zimfw/zimfw/wiki/Speed
[available modules]: https://github.com/zimfw/zimfw/wiki/Modules
[themes wiki page]: https://github.com/zimfw/zimfw/wiki/Themes

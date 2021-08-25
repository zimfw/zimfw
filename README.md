<div align="center">
  <a href="https://github.com/zimfw/zimfw">
    <img width="600" src="https://zimfw.github.io/images/zimfw-banner@2.jpg">
  </a>
</div>

What is Zim?
------------
Zim is a Zsh configuration framework with [blazing speed] and modular extensions.

Zim bundles useful [modules], a wide variety of [themes], and plenty of
customizability without compromising on speed.

What does Zim offer?
--------------------
Below is a brief showcase of Zim's features.

### Speed
<a href="https://github.com/zimfw/zimfw/wiki/Speed">
  <img src="https://zimfw.github.io/images/results.svg">
</a>

For more details, see [this wiki entry][blazing speed].

### Modules

Zim has many [modules available][modules]. Enable as many or as few as you'd like.

### Themes

To preview some of the available themes, check the [themes page][themes].

### Degit

Install modules without requiring `git` using our degit tool. It's faster and
lighter. See the [zmodule](#zmodule) usage below.

Installation
------------
Installing Zim is easy:

  * With curl:

        curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

  * With wget:

        wget -nv -O - https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

Open a new terminal and you're done. Enjoy your Zsh IMproved! Take some time to
tweak your `~/.zshrc` file, and to also check the available [modules] and [themes]
you can add to your `~/.zimrc`.

<details>
<summary>Prefer to install manually?</summary>

### Manual installation

1. Set Zsh as the default shell:

       chsh -s $(which zsh)

2. Prepend the lines in the following templates to the respective dot files:
   * [~/.zshenv](https://raw.githubusercontent.com/zimfw/install/master/src/templates/zshenv)
   * [~/.zshrc](https://raw.githubusercontent.com/zimfw/install/master/src/templates/zshrc)
   * [~/.zlogin](https://raw.githubusercontent.com/zimfw/install/master/src/templates/zlogin)
   * [~/.zimrc](https://raw.githubusercontent.com/zimfw/install/master/src/templates/zimrc)

3. Copy https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh to
   `~/.zim/zimfw.zsh`.

4. Install the modules defined in `~/.zimrc` and build the initialization scripts:

       zsh ~/.zim/zimfw.zsh install

</details>

Usage
-----

### zmodule

<pre>Usage: <b>zmodule</b> &lt;url&gt; [<b>-n</b>|<b>--name</b> &lt;module_name&gt;] [options]

Add <b>zmodule</b> calls to your <b>~/.zimrc</b> file to define the modules to be initialized. The modules are
initialized in the same order they are defined.

  &lt;url&gt;                      Module absolute path or repository URL. The following URL formats
                             are equivalent: <b>name</b>, <b>zimfw/name</b>, <b>https://github.com/zimfw/name.git</b>.
  <b>-n</b>|<b>--name</b> &lt;module_name&gt;    Set a custom module name. Default: the last component in the &lt;url&gt;.
                             Use slashes inside the name to organize the module into subdirecto-
                             ries.

Repository options:
  <b>-b</b>|<b>--branch</b> &lt;branch_name&gt;  Use specified branch when installing and updating the module.
                             Overrides the tag option. Default: the repository&apos;s default branch.
  <b>-t</b>|<b>--tag</b> &lt;tag_name&gt;        Use specified tag when installing and updating the module.
                             Overrides the branch option.
  <b>-u</b>|<b>--use</b> &lt;<b>git</b>|<b>degit</b>&gt;       Install and update the module using the defined tool. Default is
                             defined by <b>zstyle &apos;:zim:zmodule&apos; use &apos;</b>&lt;<b>git</b>|<b>degit</b>&gt;<b>&apos;</b>, or <b>git</b> if none
                             is provided.
                             <b>git</b> requires git itself. Local changes are preserved during updates.
                             <b>degit</b> requires curl or wget, and currently only works with GitHub
                             URLs. Modules install faster and take less disk space. Local changes
                             are lost during updates. Git submodules are not supported.
  <b>-z</b>|<b>--frozen</b>                Don&apos;t install or update the module.

Initialization options:
  <b>-f</b>|<b>--fpath</b> &lt;path&gt;          Add specified path to fpath. The path is relative to the module
                             root directory. Default: <b>functions</b>, if the subdirectory exists.
  <b>-a</b>|<b>--autoload</b> &lt;func_name&gt;  Autoload specified function. Default: all valid names inside the
                             module&apos;s specified fpath paths.
  <b>-s</b>|<b>--source</b> &lt;file_path&gt;    Source specified file. The file path is relative to the module root
                             directory. Default: <b>init.zsh</b>, if the <b>functions</b> subdirectory also
                             exists, or the file with largest size matching
                             <b>{init.zsh,module_name.{zsh,plugin.zsh,zsh-theme,sh}}</b>, if any exist.
  <b>-c</b>|<b>--cmd</b> &lt;command&gt;         Execute specified command. Occurrences of the <b>{}</b> placeholder in the
                             command are substituted by the module root directory path.
                             I.e., <b>-s &apos;script.zsh&apos;</b> and <b>-c &apos;source {}/script.zsh&apos;</b> are equivalent.
  <b>-d</b>|<b>--disabled</b>              Don&apos;t initialize or uninstall the module.
</pre>

### zimfw

Added new modules to `~/.zimrc`? Run `zimfw install`.

Removed modules from `~/.zimrc`? Run `zimfw uninstall`.

Want to update your modules to their latest revisions? Run `zimfw update`.

Want to upgrade `zimfw` to its latest version? Run `zimfw upgrade`.

For more information about the `zimfw` tool, run `zimfw help`.

Settings
--------

Modules are installed using `git` by default. If you don't have `git`
installed, or if you want to take advantage of our degit tool for faster and
lighter module installations, you can set degit as the default tool with:

    zstyle ':zim:zmodule' use 'degit'

By default, `zimfw` will check if it has a new version available every 30 days.
This can be disabled with:

    zstyle ':zim' disable-version-check yes

Uninstalling
------------

The best way to remove Zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshenv`, `~/.zshrc` and `~/.zlogin`.

[blazing speed]: https://github.com/zimfw/zimfw/wiki/Speed
[modules]: https://zimfw.sh/docs/modules/
[themes]: https://zimfw.sh/docs/themes/

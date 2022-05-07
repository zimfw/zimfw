<p align="center">
  <a href="https://github.com/zimfw/zimfw/releases"><img src="https://img.shields.io/github/v/release/zimfw/zimfw"></a>
  <a href="https://github.com/zimfw/zimfw/issues"><img src="https://img.shields.io/github/issues/zimfw/zimfw.svg"></a>
  <a href="https://github.com/zimfw/zimfw/network/members"><img src="https://img.shields.io/github/forks/zimfw/zimfw.svg"></a>
  <a href="https://github.com/zimfw/zimfw/stargazers"><img src="https://img.shields.io/github/stars/zimfw/zimfw.svg"></a>
  <a href="https://github.com/zimfw/zimfw/releases"><img src="https://img.shields.io/github/downloads/zimfw/zimfw/total.svg"></a>
  <a href="https://github.com/zimfw/zimfw/discussions"><img src="https://img.shields.io/badge/forum-online-green.svg"></a>
  <a href="https://github.com/zimfw/zimfw/blob/master/LICENSE"><img alt="GitHub" src="https://img.shields.io/github/license/zimfw/zimfw"></a>
</p>

<div align="center">
  <a href="https://github.com/zimfw/zimfw">
    <img width="600" src="https://zimfw.github.io/images/zimfw-banner@2.jpg">
  </a>
</div>

What is Zim?
------------
Zim is a Zsh configuration framework that bundles a [plugin manager](#usage),
useful [modules], and a wide variety of [themes], without compromising on [speed].

Check how Zim compares to other frameworks and plugin managers:

<a href="https://github.com/zimfw/zimfw/wiki/Speed">
  <img src="https://zimfw.github.io/images/results.svg">
</a>

Table of Contents
-----------------
* [Installation](#installation)
  * [Automatic installation](#automatic-installation)
  * [Manual installation](#manual-installation)
    * [Set up `~/.zshrc`](#set-up-zshrc)
    * [Create `~/.zimrc`](#create-zimrc)
* [Usage](#usage)
  * [`zmodule`](#zmodule)
  * [`zimfw`](#zimfw)
* [Settings](#settings)
* [Uninstalling](#uninstalling)

Installation
------------
Installing Zim is easy. You can choose either the automatic or manual method below:

### Automatic installation

This will install a predefined set of modules and a theme for you.

* With `curl`:

      curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

* With `wget`:

      wget -nv -O - https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

Restart your terminal and you're done. Enjoy your Zsh IMproved! Take some time
to tweak your [`~/.zshrc`](#set-up-zshrc) file, and to also check the available
[modules] and [themes] you can add to your [`~/.zimrc`](#create-zimrc).

### Manual installation

1. Set Zsh as the default shell, if you haven't done so already:
    ```zsh
    chsh -s $(which zsh)
    ````

2. [Set up your `~/.zshrc` file](#set-up-zshrc)

3. [Create your `~/.zimrc` file](#create-zimrc)

4. Restart your terminal and you're done. Enjoy your Zsh IMproved!

#### Set up `~/.zshrc`

Add the lines below to your `~/.zshrc` file, in the following order:

1. To use our `degit` tool by default to install modules:
   ```zsh
   zstyle ':zim:zmodule' use 'degit'
   ````
   This is optional, and only required if you don't have `git` installed (yes,
   Zim works even without `git`!)

2. To set where the directory used by Zim will be located:
   ```zsh
   ZIM_HOME=~/.zim
   ```
   The value of `ZIM_HOME` can be any directory your user has write access to.
   You can even set it to a cache directory like `${XDG_CACHE_HOME}/zim` or
   `~/.cache/zim` if you also include the step below, that automatically
   downloads the `zimfw` plugin manager.

3. To automatically download the `zimfw` plugin manager if missing:
   ```zsh
   # Download zimfw plugin manager if missing.
   if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
     curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
         https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
   fi
   ```
   Or if you use `wget` instead of `curl`:
   ```zsh
   # Download zimfw plugin manager if missing.
   if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
     mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
         https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
   fi
   ```
   This is optional. If you choose to not include this step, you should manually
   download the `zimfw.zsh` script once and keep it at `${ZIM_HOME}`.

4. To automatically install missing modules and update the initialization script
   if missing or outdated:
   ```zsh
   # Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
   if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
     source ${ZIM_HOME}/zimfw.zsh init -q
   fi
   ```
   This step is optional, but highly recommended. If you choose to not include
   it, you must remember to manually run `zimfw install` every time after you
   update your [`~/.zimrc`](#create-zimrc) file.

5. To source the initialization script, that initializes your modules:
   ```zsh
   # Initialize modules.
   source ${ZIM_HOME}/init.zsh
   ```

#### Create `~/.zimrc`

You must create your `.zimrc` file at `~/.zimrc`, if the `ZDOTDIR` environment
variable is not defined. Otherwise, it must be at `${ZDOTDIR}/.zimrc`. It's
referred to as `~/.zimrc` in the documentation for the sake of simplicity.

You can start with just:
```zsh
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```

If you also want one of our prompt [themes]:
```
zmodule asciiship
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```

If you want to use our [completion] module too, instead of using `compinit` directly:
```zsh
zmodule asciiship
zmodule zsh-users/zsh-completions --fpath src
zmodule completion
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```
The [completion] module calls `compinit` for you. You should remove any
`compinit` calls from your `~/.zshrc` when you use this module. The modules will
be initialized in the order they are defined, and [completion] must be
initialized *after* all modules that add completion definitions, so it must come
after [zsh-users/zsh-completions].

Check the [`zmodule` usage](#zmodule) below for more examples on how to use it to
define the modules you want to use.

Usage
-----
The `zimfw` plugin manager builds an initialization script, at `${ZIM_HOME}/init.zsh`,
that initializes the modules you defined in your `~/.zimrc` file.

The `~/.zimrc` file must contain a `zmodule` call for each module you want to
use. The modules will be initialized in the order they are defined.

The `~/.zimrc` file is not sourced during Zsh startup, and it's only used to
configure the `zimfw` plugin manager.

Check [examples of `~/.zimrc` files](#create-zimrc) above.

### zmodule

Below are some usage examples:

  * A module from the [@zimfw] organization: `zmodule archive`
  * A module from another GitHub organization: `zmodule StackExchange/blackbox`
  * A module with a custom URL: `zmodule https://gitlab.com/Spriithy/basher.git`
  * A module at an absolute path, that is already installed:
    `zmodule /usr/local/share/zsh-autosuggestions`
  * A module with a custom fpath: `zmodule zsh-users/zsh-completions --fpath src`
  * A module with a custom initialization file, and with git submodules disabled:
    `zmodule spaceship-prompt/spaceship-prompt --source spaceship.zsh --no-submodules` or
    `zmodule spaceship-prompt/spaceship-prompt --name spaceship --no-submodules`
  * A module with two custom initialization files:
    `zmodule sindresorhus/pure --source async.zsh --source pure.zsh`
  * A module with a custom initialization command:
    `zmodule skywind3000/z.lua --cmd 'eval "$(lua {}/z.lua --init zsh enhanced once)"'`
  * A module with an on-pull command. It can be used to create a cached initialization script:
    `zmodule skywind3000/z.lua --on-pull 'lua z.lua --init zsh enhanced once >! init.zsh'`
  * A module with a big git repository: `zmodule romkatv/powerlevel10k --use degit`

<details id="zmodule-usage">
<summary>Want help with the complete <code>zmodule</code> usage?</summary>

<pre>Usage: <b>zmodule</b> &lt;url&gt; [<b>-n</b>|<b>--name</b> &lt;module_name&gt;] [options]

Add <b>zmodule</b> calls to your <b>~/.zimrc</b> file to define the modules to be initialized. The modules
are initialized in the same order they are defined.

  &lt;url&gt;                      Module absolute path or repository URL. The following URL formats
                             are equivalent: <b>foo</b>, <b>zimfw/foo</b>, <b>https://github.com/zimfw/foo.git</b>.
  <b>-n</b>|<b>--name</b> &lt;module_name&gt;    Set a custom module name. Default: the last component in &lt;url&gt;.
                             Use slashes inside the name to organize the module into subdirec-
                             tories.

Repository options:
  <b>-b</b>|<b>--branch</b> &lt;branch_name&gt;  Use specified branch when installing and updating the module.
                             Overrides the tag option. Default: the repository default branch.
  <b>-t</b>|<b>--tag</b> &lt;tag_name&gt;        Use specified tag when installing and updating the module. Over-
                             rides the branch option.
  <b>-u</b>|<b>--use</b> &lt;<b>git</b>|<b>degit</b>&gt;       Install and update the module using the defined tool. Default is
                             either defined by <b>zstyle &apos;:zim:zmodule&apos; use &apos;</b>&lt;<b>git</b>|<b>degit</b>&gt;<b>&apos;</b>, or <b>git</b>
                             if none is provided.
                             <b>git</b> requires git itself. Local changes are preserved on updates.
                             <b>degit</b> requires curl or wget, and currently only works with GitHub
                             URLs. Modules install faster and take less disk space. Local
                             changes are lost on updates. Git submodules are not supported.
  <b>--no-submodules</b>            Don&apos;t install or update git submodules.
  <b>-z</b>|<b>--frozen</b>                Don&apos;t install or update the module.
  <b>--on-pull</b> &lt;command&gt;        Execute command after installing or updating the module. The com-
                             mand is executed in the module root directory.

Initialization options:
  <b>-f</b>|<b>--fpath</b> &lt;path&gt;          Add specified path to fpath. The path is relative to the module
                             root directory. Default: <b>functions</b>, if the subdirectory exists.
  <b>-a</b>|<b>--autoload</b> &lt;func_name&gt;  Autoload specified function. Default: all valid names inside the
                             <b>functions</b> subdirectory, if any.
  <b>-s</b>|<b>--source</b> &lt;file_path&gt;    Source specified file. The file path is relative to the module
                             root directory. Default: <b>init.zsh</b>, if the <b>functions</b> subdirectory
                             also exists, or the largest of the files with name matching
                             <b>{init.zsh,module_name.{zsh,plugin.zsh,zsh-theme,sh}}</b>, if any.
  <b>-c</b>|<b>--cmd</b> &lt;command&gt;         Execute specified command. Occurrences of the <b>{}</b> placeholder in
                             the command are substituted by the module root directory path.
                             I.e., <b>-s &apos;foo.zsh&apos;</b> and <b>-c &apos;source {}/foo.zsh&apos;</b> are equivalent.
  <b>-d</b>|<b>--disabled</b>              Don&apos;t initialize or uninstall the module.

  Setting any initialization option above will disable all the default values from the other
  initialization options, so only your provided values are used. I.e. these values are either
  all automatic, or all manual.
</pre>

</details>

### zimfw

The Zim plugin manager:

  * Added new modules to `~/.zimrc`? Run `zimfw install`.
  * Removed modules from `~/.zimrc`? Run `zimfw uninstall`.
  * Want to update your modules to their latest revisions? Run `zimfw update`.
  * Want to upgrade `zimfw` to its latest version? Run `zimfw upgrade`.
  * For more information about the `zimfw` plugin manager, run `zimfw help`.

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

[modules]: https://zimfw.sh/docs/modules/
[themes]: https://zimfw.sh/docs/themes/
[speed]: https://github.com/zimfw/zimfw/wiki/Speed
[@zimfw]: https://github.com/zimfw
[completion]: https://github.com/zimfw/completion
[zsh-users/zsh-completions]: https://github.com/zsh-users/zsh-completions

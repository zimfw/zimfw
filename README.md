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

4. To automatically install missing modules and update the static initialization
   script if missing or outdated:
   ```zsh
   # Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
   if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
     source ${ZIM_HOME}/zimfw.zsh init -q
   fi
   ```
   This step is optional, but highly recommended. If you choose to not include
   it, you must remember to manually run `zimfw install` every time after you
   update your [`~/.zimrc`](#create-zimrc) file.

5. To source the static script, that will initialize your modules:
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
The `zimfw` plugin manager installs your modules at `${ZIM_HOME}/modules`, and
builds a static script at `${ZIM_HOME}/init.zsh` that will initialize them. Your
modules are defined in your `~/.zimrc` file.

The `~/.zimrc` file must contain `zmodule` calls to define the modules to be
initialized. The initialization will be done in the same order it's defined.

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
    `zmodule sindresorhus/pure --source async.zsh --source pure.zsh`. Separate
    zmodule calls can also be used. In this equivalent example, the second call
    automatically discovers the second file to be sourced:
    ```
    zmodule sindresorhus/pure --source async.zsh
    zmodule sindresorhus/pure
    ```
  * A module with a custom initialization command:
    `zmodule skywind3000/z.lua --cmd 'eval "$(lua {}/z.lua --init zsh enhanced once)"'`
  * A module with an on-pull command. It can be used to create a cached initialization script:
    `zmodule skywind3000/z.lua --on-pull 'lua z.lua --init zsh enhanced once >! init.zsh'`
  * A module with a big git repository: `zmodule romkatv/powerlevel10k --use degit`
  * A module with a custom root subdirectory: `zmodule ohmyzsh/ohmyzsh --root plugins/vim-interaction`
  * A module with multiple roots:
    ```
    zmodule sorin-ionescu/prezto --root modules/command-not-found
    zmodule sorin-ionescu/prezto --root modules/gnu-utility
    ```
    or
    ```
    zmodule ohmyzsh/ohmyzsh --root plugins/perl
    zmodule ohmyzsh/ohmyzsh --root plugins/vim-interaction
    ```

<details id="zmodule-usage">
<summary>Want help with the complete <code>zmodule</code> usage?</summary>

<pre>Usage: <b>zmodule</b> &lt;url&gt; [<b>-n</b>|<b>--name</b> &lt;module_name&gt;] [<b>-r</b>|<b>--root</b> &lt;path&gt;] [options]

Add <b>zmodule</b> calls to your <b>~/.zimrc</b> file to define the modules to be initialized. The initiali-
zation will be done in the same order it&apos;s defined.

  &lt;url&gt;                      Module absolute path or repository URL. The following URL formats
                             are equivalent: <b>foo</b>, <b>zimfw/foo</b>, <b>https://github.com/zimfw/foo.git</b>.
                             If an absolute path is given, the module is considered externally
                             installed, and won&apos;t be installed or updated by zimfw.
  <b>-n</b>|<b>--name</b> &lt;module_name&gt;    Set a custom module name. Default: the last component in &lt;url&gt;.
                             Slashes can be used inside the name to organize the module into
                             subdirectories. The module will be installed at
                             <b>${ZIM_HOME}/</b>&lt;module_name&gt;.
  <b>-r</b>|<b>--root</b> &lt;path&gt;           Relative path to the module root.

Per-module options:
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

  The per-module options above are carried over multiple zmodule calls for the same module.
  Modules are uniquely identified by their name.

Per-module-root options:
  <b>--if</b> &lt;test&gt;                Will only initialize module root if specified test returns a zero
                             exit status. The test is evaluated at every new terminal startup.
  <b>--if-command</b> &lt;command&gt;     Will only initialize module root if specified external command is
                             available. This is evaluated at every new terminal startup.
                             Equivalent to <b>--if "(( \\\${+commands[\${1}]} ))"</b>.
  <b>--on-pull</b> &lt;command&gt;        Execute command after installing or updating the module. The com-
                             mand is executed in the module root directory.
  <b>-d</b>|<b>--disabled</b>              Don&apos;t initialize the module root or uninstall the module.

  The per-module-root options above are carried over multiple zmodule calls for the same mod-
  ule root.

Per-call initialization options:
  <b>-f</b>|<b>--fpath</b> &lt;path&gt;          Will add specified path to fpath. The path is relative to the
                             module root directory. Default: <b>functions</b>, if the subdirectory
                             exists and is non-empty.
  <b>-a</b>|<b>--autoload</b> &lt;func_name&gt;  Will autoload specified function. Default: all valid names inside
                             the <b>functions</b> subdirectory, if any.
  <b>-s</b>|<b>--source</b> &lt;file_path&gt;    Will source specified file. The path is relative to the module
                             root directory. Default: <b>init.zsh</b>, if a non-empty <b>functions</b> sub-
                             directory exists, else the largest of the files matching the glob
                             <b>(init.zsh|</b>&lt;name&gt;<b>.(zsh|plugin.zsh|zsh-theme|sh))</b>, if any.
                             &lt;name&gt; in the glob is resolved to the last component of the mod-
                             ule name, or the last component of the path to the module root.
  <b>-c</b>|<b>--cmd</b> &lt;command&gt;         Will execute specified command. Occurrences of the <b>{}</b> placeholder
                             in the command are substituted by the module root directory path.
                             I.e., <b>-s &apos;foo.zsh&apos;</b> and <b>-c &apos;source {}/foo.zsh&apos;</b> are equivalent.

  Setting any per-call initialization option above will disable the default values from the
  other per-call initialization options, so only your provided values will be used. I.e. these
  values are either all automatic, or all manual in each zmodule call. To use default values
  and also provided values, use separate zmodule calls.
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
Customize path of the directory used by Zim with the `ZIM_HOME` environment
variable:

    ZIM_HOME=~/.zim

By default, the `zimfw` plugin manager configuration file must be at `~/.zimrc`,
if the `ZDOTDIR` environment variable is not defined. Otherwise, it must be at
`${ZDOTDIR}/.zimrc`. You can customize its full path and name with the
`ZIM_CONFIG_FILE` environment variable:

    ZIM_CONFIG_FILE=~/.config/zsh/zimrc

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

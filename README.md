<p align="center">
<a href="https://github.com/zimfw/zimfw/releases"><img src="https://img.shields.io/github/v/release/zimfw/zimfw"></a>
<a href="https://github.com/zimfw/zimfw/issues"><img src="https://img.shields.io/github/issues/zimfw/zimfw.svg"></a>
<a href="https://img.shields.io/github/forks/zimfw/zimfw.svg"><img src="https://img.shields.io/github/forks/zimfw/zimfw.svg"></a>
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
Zim is a Zsh configuration framework with [blazing speed] and modular extensions.

Zim bundles a plugin manager, useful [modules], and a wide variety of [themes],
without compromising on speed.

See how it compares to other frameworks and plugin managers:

<a href="https://github.com/zimfw/zimfw/wiki/Speed">
  <img src="https://zimfw.github.io/images/results.svg">
</a>

## Table of Contents

- [Installation](#installation)
  + [Manual installation](#manual-installation)
  + [Automatic installation](#automatic-installation)
- [Usage](#usage)
  + [Example Configuration](#example-configuration)
- [Settings](#settings)
  + [`zmodule`](#zmodule)
  + [`zimfw`](#zimfw)
- [Uninstalling](#uninstalling)
- [FAQ](#faq)
  + [How can I change default `zimrc` file location?](#how-can-i-change-default-zimrc-file-location)
  + [How can I speed up module installation?](#how-can-i-speed-up-module-installation)
  + [How to disabel automatic updates?](#how-to-disabel-automatic-updates)
  + [When should I call `compinit` in my `zshrc` ?](#when-should-i-call-compinit-in-my-zshrc)

Installation
------------
Installing Zim is easy. You can choose either the manual or automatic method
below:

### Manual installation

1. Set Zsh as the default shell, if you haven't done so already:
    ```zsh
    chsh -s $(which zsh)
    ````

2. If you don't have `git` installed, first add this line to your `.zshrc` file
   (yes, Zim works even without `git`!):
    ```zsh
    zstyle ':zim:zmodule' use 'degit'
    ````

3. Add these lines to your `~/.zshrc`:
    ```zsh
    ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
    # Download zimfw plugin manager if missing.
    if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
      curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
          https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    fi
    # Install missing plugins, and update ${ZIM_HOME}/init.zsh if missing or outdated.
    if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
      source ${ZIM_HOME}/zimfw.zsh init -q
    fi
    # Initialize plugins.
    source ${ZIM_HOME}/init.zsh
    ```
    Or if you use `wget` instead of `curl`:
    ```zsh
    ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
    # Download zimfw plugin manager if missing.
    if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
      mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
          https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    fi
    # Install missing plugins, and update ${ZIM_HOME}/init.zsh if missing or outdated.
    if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
      source ${ZIM_HOME}/zimfw.zsh init -q
    fi
    # Initialize plugins.
    source ${ZIM_HOME}/init.zsh
    ```

4. Create a `~/.zimrc` file, and add a `zmodule` call for each plugin you want
   to use. The `~/.zimrc` file is not sourced during the Zsh startup, and it's
   only used to configure the `zimfw` plugin manager.

   See the `zmodule` usage below.

   For example, you can start with just:
   ```zsh
   zmodule zsh-users/zsh-syntax-highlighting
   zmodule zsh-users/zsh-autosuggestions
   ```
   Or if you also want to use completions:
   ```zsh
   zmodule zsh-users/zsh-completions
   zmodule completion
   zmodule zsh-users/zsh-syntax-highlighting
   zmodule zsh-users/zsh-autosuggestions
   ```
   The `zmodule completion` is a Zim module that calls `compinit` for you. So no
   need to have `compinit` in your `~/.zshrc` when you use this module.

   Check the available [modules] and [themes] you can add to your `~/.zimrc`.

5. Restart your terminal to automatically download the `zimfw` plugin manager,
   install the plugins defined in `~/.zimrc`, and initialize them. Enjoy your
   Zsh IMproved!

### Automatic installation

This will install a predefined set of modules and a theme.

* With curl:

      curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

* With wget:

      wget -nv -O - https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

Open a new terminal and you're done. Enjoy your Zsh IMproved! Take some time to
tweak your `~/.zshrc` file, and to also check the available [modules] and [themes]
you can add to your `~/.zimrc`.

Usage
-----

By default, Zim looks for the configuration file in `{ZDOTDIR:-${HOME}}/.zimrc`. If using the automatic installer, the `ZIM_HOME` environment variable is set to `${ZDOTDIR:-${HOME}}/.zim`.

Add `zmodule` calls to your `{ZDOTDIR:-${HOME}}/.zimrc` file to define the modules to be
initialized, then run `zimfw install` to install them.

### Example configuration

Example configuration file with [zsh-completions](https://github.com/zsh-users/zsh-completions), [autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) and [syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) plugins installation:
```zsh
zmodule completions
zmodule zsh-users/zsh-completions
zmodule zsh-users/zsh-autosuggestions
zmodule zsh-users/zsh-syntax-highlighting
```
The first line is to install module named _completions_ as can be seen from the [modules] section in [Docs](https://zimfw.sh/docs/). This provides more convenience when using plugins with completions.

Settings
--------

Below are brief description about some of the Zim components

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

The command line utility for Zim:

  * Added new modules to `~/.zimrc`? Run `zimfw install`.
  * Removed modules from `~/.zimrc`? Run `zimfw uninstall`.
  * Want to update your modules to their latest revisions? Run `zimfw update`.
  * Want to upgrade `zimfw` to its latest version? Run `zimfw upgrade`.
  * For more information about the `zimfw` utility, run `zimfw help`.

FAQ
----

### 1. How can I change default `zimrc` file location?

You cannot change the default .zimrc location, it must be in ${ZDOTDIR:-${HOME}}/.zimrc. You can change the `ZDOTDIR` location. Change it to the desired path.
Eg: Set this in your `~/.zshenv` to change path of `zimrc` to `~/.config/zsh/.zimrc`:
`export ZDOTDIR="${HOME}/.config/zsh"`

### 2. How can I speed up module installation?

Modules are installed using `git` by default. If you don't have `git`
installed, or if you want to take advantage of our degit tool for faster and
lighter module installations, you can set degit as the default tool with:

    zstyle ':zim:zmodule' use 'degit'

### 3. How to disabel automatic updates?

By default, `zimfw` will check if it has a new version available every 30 days.
This can be disabled with:

    zstyle ':zim' disable-version-check yes

### 4. When should I call `compinit` in my `zshrc` ?

`compinit` is called by _completions_ module as shown in the [Example configuration](https://github.com/zimfw/zimfw#example-configuration). So, if you are using that module then remove any call to `compinit` in your `.zshrc` like:
```sh
autoload -Uz compinit
compinit
# End of lines added by compinstall
```
which maybe present after fresh install of zsh or anywhere in your system-wide zsh files like `/etc/zsh/zshrc` which comes with some installations using distro package manager. Otherwise, add:
```sh
autoload -Uz compinit
compinit
```
before `zmodule ...` calls in your `.zshrc`

Uninstalling
------------

The best way to remove Zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshenv`, `~/.zshrc` and `~/.zlogin`.

[blazing speed]: https://github.com/zimfw/zimfw/wiki/Speed
[modules]: https://zimfw.sh/docs/modules/
[themes]: https://zimfw.sh/docs/themes/
[@zimfw]: https://github.com/zimfw

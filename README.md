Zsh IMproved FrameWork
======================

<div align="center">
  <a href="https://github.com/zimfw/zimfw">
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

### Fish-shell history navigation
![history-substring-search][fish_shell]

### Syntax highlighting
![syntax-highlighting][syntax_highlighting]

### And much more!
Zim has many modules! Enable as many or as few as you'd like.

Installation
------------
Installing Zim is easy:

    curl -s --proto -all,+https https://raw.githubusercontent.com/zimfw/install/develop/install.zsh | zsh

Open a new terminal and you're done! Enjoy your Zsh IMproved! Take some time to
read about the [available modules][modules] and tweak your `.zshrc` file.

If you have a different shell framework installed (like oh-my-zsh or prezto),
*uninstall those first to prevent conflicts*.

Settings
--------

### Enabled modules

Use the following zstyle to select the modules you would like enabled:

    zstyle ':zim' modules 'first-module' 'second-module' 'third-module'

You can provide as many module names as you want. Modules are sourced in the
order given.

By default, a module is installed from the Zim repository with the same name.
For example, the `utility` module is installed from
https://<em></em>github.com/zimfw/utility.git if no additional module configuration is provided.

### Module customization

To configure a module, use the following format, where the style name is the
module name:

    zstyle ':zim:module' <module> ['frozen' yes] ['url' <url>] ['branch' <branch>|'tag' <tag>]

| Key | Description | Default value |
| --- | ----------- | ------------- |
| frozen | If set to yes, then module will not be cleaned, installed or updated. It can still be freely enabled or disabled with the modules style. | no |
| url | Repository URL or path. The following formats are equivalent: *module*, zimfw/*module*, https://<em></em>github.com/zimfw/<em>module</em>.git | *module* |
| branch | Repository branch. | master |
| tag | Repository tag. Overrides branch, if one was specified. | |

Choose the module name wisely. The first file found in the module root directory,
in the following order, will be sourced:
init.zsh, *module*.zsh, *module*.plugin.zsh, *module*.zsh.theme, *module*.sh

For example, [mafredi/zsh-async](https://github.com/mafredri/zsh-async) must be
configured as a module called `async`:

    zstyle ':zim:module' async 'url' 'mafredri/zsh-async'

because it has an async.zsh initialization file. Then to be enabled, `async` must
be added to the modules style.

### Prompt theme

Prompt themes are enabled in one of two different ways, depending on how the
specific theme you want works:

  1. If it has a prompt_<em>module</em>_setup file: it is enabled with Zim's
     `prompt` module. See [the instructions
     here](https://github.com/zimfw/prompt/blob/master/README.md#settings). All
     [Zim themes](https://github.com/zimfw/zimfw/wiki/Themes) work this way.
     The advantage of these themes is that you can customize them with
     additional parameters.
  2. If it has one of the initialization files listed above: it is enabled when
     it's sourced, not with Zim's `prompt` module. The last sourced prompt
     overrides any previous ones.

Updating
--------

To update your modules, run:

    zimfw update

To upgrade Zim, run:

    zimfw upgrade

For more information about the `zimfw` tool, run `zimfw` with no parameters.

Uninstalling
------------

The best way to remove Zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshrc` and `~/.zlogin`.

[fish_shell]: https://i.eriner.me/zim_history-substring-search.gif
[syntax_highlighting]: https://i.eriner.me/zim_syntax-highlighting.gif
[speed]: https://github.com/zimfw/zimfw/wiki/Speed
[modules]: https://github.com/zimfw/zimfw/wiki/Modules
[themes]: https://github.com/zimfw/zimfw/wiki/Themes

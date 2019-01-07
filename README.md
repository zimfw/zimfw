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
Installing Zim is easy. If you have a different shell framework installed (like oh-my-zsh or prezto),
*uninstall those first to prevent conflicts*. It can be installed manually by following the instructions below:

1. Start a Zsh shell:

       zsh

2. Clone the repository:

       git clone --recursive https://github.com/zimfw/zimfw.git ${ZDOTDIR:-${HOME}}/.zim

3. Paste this into your terminal to prepend the initialization templates to your configs:

       for template_file in ${ZDOTDIR:-${HOME}}/.zim/templates/*; do
         user_file="${ZDOTDIR:-${HOME}}/.${template_file:t}"
         cat ${template_file} ${user_file}(.N) > ${user_file}.tmp && mv ${user_file}{.tmp,}
       done

4. Set Zsh as the default shell:

       chsh -s =zsh

5. Open a new terminal and install the enabled modules.

       zimfw install

6. Finish optimization (this is only needed once, hereafter it will happen upon
   desktop/tty login):

       zimfw login-init

7. You're done! Enjoy your Zsh IMproved! Take some time to read about the
   [available modules][modules] and tweak your `.zshrc` file.

Settings
--------

### Enabled modules

Use the following zstyle to select the modules you would like enabled:

    zstyle ':zim' modules 'first-module' 'second-module' 'third-module'

You can provide as many module names as you want. Modules are sourced in the
order given.

By default, a module is installed from the Zim repository with the same name.
For example, the `git` module is installed from https://github.com/zimfw/git if
no additional module configuration is provided.

### Module customization

To configure a module, use the following format (where the style name is the
module name):

    zstyle ':zim:module' <module> ['frozen' yes] ['url' <url>] ['branch' <branch>|'tag' <tag>]

If `frozen` is set to `yes`, then the module will not be cleaned, installed or
updated.

You can provide a custom `url` with the following equivalent formats:
  * `module`
  * `zimfw/module`
  * `https://github.com/zimfw/module.git`

If no `branch` or `tag` name is given, then the default is `branch` `master`.

Choose the module name wisely. The first file found in the module root directory,
in the following order, will be sourced (where `module` is the module name):
  1. `init.zsh`
  2. `module.zsh`
  3. `module.plugin.zsh`
  4. `module.zsh.theme`
  5. `module.sh`

For example, https://github.com/mafredri/zsh-async must be configured as:

    zstyle ':zim:module' async 'url' 'mafredri/zsh-async'

because it has a `async.zsh` initialization file, then enabled as `async` in the
`modules` style.

### Prompt theme

Prompt themes are enabled in one of two different ways, depending on how the
specific theme you want works:

  1. If it has a `prompt_module_setup` file (where `module` is the module name):
     it is enabled with Zim's `prompt` module. See [the instructions
     here](https://github.com/zimfw/prompt/blob/master/README.md#settings). The
     advantage of these themes is that you can customize them with additional
     parameters. All [Zim themes](https://github.com/zimfw/zimfw/wiki/Themes)
     work this way.
  2. If it has one of the initialization files listed above: it is enabled when
     it's sourced, not with Zim's `prompt` module.

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

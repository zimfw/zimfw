ZIM - Zsh IMproved
==================

<div align="center">
  <a href="https://github.com/Eriner/zim">
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

### Fish-shell History Navigation
![history-substring-search][fish_shell]

### Syntax Highlighting
![syntax-highlighting][syntax_highlighting]

### And much more!
Zim has many modules! Enable as many or as few as you'd like.

Installation
------------
Installing Zim is easy. Just run one of these commands:

#### via curl
  ```
  sh -c "$(curl -fsSL --proto-redir -all,https https://raw.githubusercontent.com/Eriner/zim/master/tools/zim_install)"
  ```

#### via wget
  ```
  sh -c "$(wget -q --secure-protocol=auto https://raw.githubusercontent.com/Eriner/zim/master/tools/zim_install) -O -)"
  ```

That's all there is to it. Enjoy your Zsh IMproved! Take some time to read about the [available modules][modules] and tweak your `.zshrc` file.

Updating
--------

To update zim, run:

```
zmanage update
```

For more information about the `zmanage` tool, see the [meta module][meta-module] documentation.

Uninstalling
------------

The best way to remove zim is to manually delete `~/.zim`, `~/.zimrc`, and
remove the initialization lines from your `~/.zshrc`.

However, there are some **experimental** convenience functions to remove zim:

**NOTE: This functionality is experimental!**

To remove zim, run:
```
zmanage remove
```

**NOTE: This functionality is experimental!**


[fish_shell]: https://i.eriner.me/zim_history-substring-search.gif
[syntax_highlighting]: https://i.eriner.me/zim_syntax-highlighting.gif
[speed]: https://github.com/Eriner/zim/wiki/Speed
[modules]: https://github.com/Eriner/zim/wiki/Modules
[themes]: https://github.com/Eriner/zim/wiki/Themes
[meta-module]: https://github.com/Eriner/zim/tree/master/modules/meta

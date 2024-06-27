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

# Zim(中国镜像安装版本)

什么是Zim？
-----------
Zim是一个Zsh配置框架，集成了[插件管理器](#usage)、有用的[模块]和多种[主题]，同时不牺牲[速度]。

查看Zim与其他框架和插件管理器的比较：

<a href="https://github.com/zimfw/zimfw/wiki/Speed">
  <img src="https://zimfw.github.io/images/results.svg">
</a>

目录
-----
* [安装](#installation)
  * [自动安装](#automatic-installation)
  * [手动安装](#manual-installation)
    * [设置 `~/.zshrc`](#set-up-zshrc)
    * [创建 `~/.zimrc`](#create-zimrc)
* [使用](#usage)
  * [`zmodule`](#zmodule)
  * [`zimfw`](#zimfw)
* [设置](#settings)
* [卸载](#uninstalling)

安装
------------
安装Zim很简单。你可以选择下面的自动或手动方法：

### 自动安装

这将为你安装预定义的模块集合和主题。

* 使用 `curl`：
  ```zsh
  curl -fsSL https://gitee.com/dawn_magnet/zimfw-install/raw/master/install.zsh | zsh
  ```

* 使用 `wget`：
  ```zsh
  wget -nv -O - https://gitee.com/dawn_magnet/zimfw-install/raw/master/install.zsh | zsh
  ```

重启你的终端，你就完成了。享受你的Zsh改进版！花些时间调整你的[`~/.zshrc`](#set-up-zshrc)文件，并检查你可以添加到[`~/.zimrc`](#create-zimrc)的可用[模块]和[主题]。

### 手动安装

1. 如果你还没有设置Zsh为默认shell，请设置：
    ```zsh
    chsh -s $(which zsh)
    ```

2. [设置你的 `~/.zshrc` 文件](#set-up-zshrc)

3. [创建你的 `~/.zimrc` 文件](#create-zimrc)

4. 重启你的终端，你就完成了。享受你的Zsh改进版！

#### 设置 `~/.zshrc`

按照以下顺序将以下行添加到你的 `~/.zshrc` 文件：

1. 使用我们的 `degit` 工具默认安装模块：
   ```zsh
   zstyle ':zim:zmodule' use 'degit'
   ```
   这是可选的，仅当你没有安装 `git` 时需要（是的，即使没有 `git`，zimfw也能工作！）

2. 设置zimfw插件管理器配置文件的位置：
   ```zsh
   ZIM_CONFIG_FILE=~/.config/zsh/zimrc
   ```
   这是可选的。`ZIM_CONFIG_FILE` 的值可以是任何你的用户至少有读取权限的路径。默认情况下，如果未定义 `ZDOTDIR` 环境变量，则文件必须在 `~/.zimrc`。否则，它必须在 `${ZDOTDIR}/.zimrc`。

3. 设置zimfw插件管理器将保存必要文件的目录：
   ```zsh
   ZIM_HOME=~/.zim
   ```
   `ZIM_HOME` 的值可以是任何你的用户有写入权限的目录。你甚至可以将其设置为像 `${XDG_CACHE_HOME}/zim` 或 `~/.cache/zim` 这样的缓存目录。

4. 如果缺少，则自动下载zimfw插件管理器：
   ```zsh
   # 如果缺少，则下载zimfw插件管理器。
   if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
     curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
         https://gitee.com/dawn_magnet/zimfw/raw/master/zimfw.zsh
   fi
   ```
   或者如果你使用 `wget` 而不是 `curl`：
   ```zsh
   # 如果缺少，则下载zimfw插件管理器。
   if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
     mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
         https://gitee.com/dawn_magnet/zimfw/raw/master/zimfw.zsh
   fi
   ```
   这是可选的。或者，你可以在任何你的用户有写入权限的地方下载 `zimfw.zsh` 脚本：只需将 `${ZIM_HOME}/zimfw.zsh` 的出现替换为你喜欢的路径，例如 `/usr/local/bin/zimfw.zsh`。如果你选择不包括这一步，你应该手动下载 `zimfw.zsh` 脚本一次并将其保存在首选路径。如果你选择不包括这一步，你应该手动下载 `zimfw.zsh` 脚本一次并将其保存在首选路径。

5. 自动安装缺失的模块并更新静态初始化脚本（如果缺少或过时）：
   ```zsh
   # 安装缺失的模块并更新 ${ZIM_HOME}/init.zsh，如果缺少或过时。
   if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
     source ${ZIM_HOME}/zimfw.zsh init -q
   fi
   ```
   这一步是可选的，但强烈推荐。如果你选择不包括它，你必须记住每次更新你的[`~/.zimrc`](#create-zimrc)文件时手动运行 `zimfw install`。如果你选择将 `zimfw.zsh` 放在前一步中提到的不同路径，请将 `${ZIM_HOME}/zimfw.zsh` 替换为所选择的路径。

6. 调用静态脚本，它将初始化你的模块：
   ```zsh
   # 初始化模块。
   source ${ZIM_HOME}/init.zsh
   ```

#### 创建 `~/.zimrc`

此文件配置zimfw插件管理器。出于简单起见，在文档中被称为 `~/.zimrc`，但文件的实际位置由以下规则定义：

1. 你可以使用 `ZIM_CONFIG_FILE` 环境变量定义文件的完整路径和名称。例如：
   ```zsh
   ZIM_CONFIG_FILE=~/.config/zsh/zimrc
   ```

2. 或者，如果你定义了 `ZDOTDIR` 环境变量，那么文件必须在 `${ZDOTDIR}/.zimrc`

3. 否则，它必须在 `~/.zimrc`，这是它的默认位置。

至于文件的内容，你可以从以下开始：
```zsh
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```

如果你还想要我们的一个[提示主题]：
```zsh
zmodule git-info
zmodule duration-info
zmodule asciiship
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```

如果你想使用我们的[完成]模块，而不是直接使用 `compinit`：
```zsh
zmodule git-info
zmodule duration-info
zmodule asciiship
zmodule zsh-users/zsh-completions --fpath src
zmodule completion
zmodule zsh-users/zsh-syntax-highlighting
zmodule zsh-users/zsh-autosuggestions
```
[完成]模块会为你调用 `compinit`。当你使用这个模块时，你应该从你的 `~/.zshrc` 中移除任何 `compinit` 调用。模块将按照它们定义的顺序进行初始化，并且[完成]必须在添加完成定义的所有模块之后初始化，所以它必须在[zsh-users/zsh-completions]之后。

查看下面的 [`zmodule` 使用](#zmodule)以获取有关如何使用它的更多示例，以定义你想使用的模块。

使用
-----
zimfw插件管理器在 `${ZIM_HOME}/modules` 安装你的模块，并在 `${ZIM_HOME}/init.zsh` 构建一个静态脚本，它将初始化它们。你的模块在 `~/.zimrc` 文件中定义。

`~/.zimrc` 文件必须包含 `zmodule` 调用以定义要初始化的模块。模块将按照它们定义的顺序进行初始化。

`~/.zimrc` 文件在Zsh启动期间不会被调用，它仅用于配置zimfw插件管理器。

查看上面[`~/.zimrc` 文件的示例](#create-zimrc)。

### zmodule

以下是一些使用示例：

  * 来自 [@zimfw] 组织的模块：`zmodule archive`
  * 来自另一个GitHub组织的模块：`zmodule StackExchange/blackbox`
  * 带自定义URL的模块：`zmodule https://gitlab.com/Spriithy/basher.git` 
  * 已经安装的绝对路径的模块：
    `zmodule /usr/local/share/zsh-autosuggestions`
  * 带自定义fpath的模块：`zmodule zsh-users/zsh-completions --fpath src`
  * 带自定义初始化文件并禁用git子模块的模块：
    `zmodule spaceship-prompt/spaceship-prompt --source spaceship.zsh
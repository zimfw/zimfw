#
# This is not sourced during shell startup and is only used to configure zimfw.
#

#
# Modules
#

# Sets sane Zsh built-in environment options.
zmodule environment
# Provides handy git aliases and functions.
zmodule git
# Applies correct bindkeys for input events.
zmodule input
# Sets a custom terminal title.
zmodule termtitle
# Utility aliases and functions. Adds colour to ls, grep and less.
zmodule utility

# <-- Normally new modules should be added here. Check each module documentation
# for any caveats.

#
# Prompt
#

# Exposes how long the last command took to run to prompts.
zmodule duration-info
# Exposes git repository status information to prompts.
zmodule git-info
# A heavily reduced, ASCII-only version of the Spaceship and Starship prompts.
zmodule asciiship

#
# Completion
#

# Additional completion definitions for Zsh.
zmodule zsh-users/zsh-completions --fpath src
# Enables and configures smart and extensive tab completion, must be sourced
# after all modules that add completion definitions.
zmodule completion

#
# Modules that must be initialized last
#

# Fish-like syntax highlighting for Zsh, must be sourced after completion.
zmodule zsh-users/zsh-syntax-highlighting
# Fish-like history search for Zsh, must be sourced after
# zsh-users/zsh-syntax-highlighting.
zmodule zsh-users/zsh-history-substring-search
# Fish-like autosuggestions for Zsh. Add the following to your ~/.zshrc to boost
# performance: ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zmodule zsh-users/zsh-autosuggestions

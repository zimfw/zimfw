#
# Gitster theme
# https://github.com/shashankmehta/dotfiles/blob/master/thesetup/zsh/.oh-my-zsh/custom/themes/gitster.zsh-theme
#

gst_get_status() {
  print "%(?:%F{10}➜ :%F{9}➜ %s)"
}

gst_get_pwd() {
  prompt_short_dir="$(short_pwd)"
  git_root="$(command git rev-parse --show-toplevel 2> /dev/null)" && \
  prompt_short_dir="${prompt_short_dir#${$(short_pwd $git_root):h}/}"
  print ${prompt_short_dir}
}

prompt_gitster_precmd() {
  PROMPT='$(gst_get_status) %F{white}$(gst_get_pwd) $(git_prompt_info)%f '
}

prompt_gitster_setup() {
  ZSH_THEME_GIT_PROMPT_PREFIX="%F{cyan}"
  ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
  ZSH_THEME_GIT_PROMPT_DIRTY=" %F{yellow}✗%f"
  ZSH_THEME_GIT_PROMPT_CLEAN=" %F{green}✓%f"

  autoload -Uz add-zsh-hook

  add-zsh-hook precmd prompt_gitster_precmd
  prompt_opts=(cr subst percent)
}

prompt_gitster_setup "$@"

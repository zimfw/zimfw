Environment
===========

Sets generic Zsh built-in environment options.

Also enables smart URL-pasting. This prevents the user from having to manually escape URLs.

Uses `.zimrc` defined `${ztermtitle}` variable to set the terminal title, if defined.

ZSH Options
-----------

| Option | Effect |
| ------ | ------ |
| AUTO_RESUME | Resume existing jobs before creating a new job |
| LONG_LIST_JOBS | Use the verbose list format by default |
| NOTIFY | Report job status immediately instead of waiting for new prompt |
| INTERACTIVE_COMMENTS | Recognize comments starting with `#` |
| BG_NICE | Disabled to prevent jobs being given a lower priority |
| HUP | Disabed to prevent SIGHUP to jobs on shell close |
| CHECK_JOBS | Disabled to prevent job report on shell close |

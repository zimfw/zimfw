environment
===========

Sets generic zsh built-in environment options.

Also enables smart URL-pasting. This prevents the user from having to manually escape URLs.

Uses `.zimrc` defined `${ztermtitle}` variable to set the terminal title, if defined.

zsh options
-----------

  * `AUTO_RESUME` resumes an existing job before creating a new one.
  * `INTERACTIVE_COMMENTS` allows comments starting with `#` in the shell.
  * `LONG_LIST_JOBS` lists jobs in verbose format by default.
  * `NOTIFY` reports job status immediately instead of waiting for the prompt.
  * `NO_BG_NICE` prevents background jobs being given a lower priority.
  * `NO_CHECK_JOBS` prevents status report of jobs on shell exit.
  * `NO_HUP` prevents SIGHUP to jobs on shell exit.

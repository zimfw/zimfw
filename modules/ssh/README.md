SSH
===

Provides a convenient way to load ssh-agent. This enables one-time login and caching of SSH credentials per session.

.zimrc Configuration
--------------------

  * `zssh_ids=(id_rsa)` add any identities (from ~/.ssh) to this list to have them loaded and cached on login.

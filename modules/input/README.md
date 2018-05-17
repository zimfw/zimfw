input
=====

Applies correct bindkeys for input events.

Without this module, you may experience oddities in how zsh interprets input.
For example, pressing LEFT and then the DELETE key may capitalize characters
rather than delete them.

This module also provides double-dot parent directory expansion.
It can be enabled by uncommenting `zdouble_dot_expand='true'` in your `.zimrc`.

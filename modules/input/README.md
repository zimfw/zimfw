Input
=====

Applies correct bindkeys for input events.

Without this module, you may experience oddities in how Zsh interprets input.
For example, using the UP key, then using the back arrow and pressing DELETE may capatalize characters rather than delete them. 

This module also provides double-dot parent directory expansion.
It can be enabled by uncommenting `zdouble_dot_expand='true'` in your .zimrc

custom
======

Add any custom aliases/settings to the `init.zsh` file.

Any functions should go in the `functions` subdirectory, where the name of the
file is the name of the function.

For example, this function from your `.zshrc`:
```zsh
foo() {
  print 'bar'
}
```

becomes a file named `foo` in the `functions` subdirectory containing:
```zsh
print 'bar'
```

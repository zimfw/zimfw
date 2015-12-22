Custom
======

Add any custom aliases/settings to the `init.zsh` file.

Any functions should go in the `functions` folder, where the name of the file is the name of the function.

For example, this function from your .zshrc:
```
foo() {
  print 'bar'
}
```

becomes a file named 'foo' in the functions folder containing:
```
print 'bar'
```

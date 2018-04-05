Pacman
======

Adds aliases for the pacman package manager.

Also includes optional helper(s).

.zimrc Configuration
-------------
  * `zpacman_frontend='helper_here'` Set helper_here to a wrapper if applicable (powerpill, pacmatic, etc).
  * `zpacman_helper=(aur)` add/remove any helper scripts to be loaded here.

Helpers
-------

### aur

provides simple AUR helper aliases.

  * `aurb package_name` clone the package from the AUR, build, and install.
  * `aurd package_name` clone the package from the AUR, but do not build.
  * `auru` run inside a directory created with `aurb`, this will update, build, and install a package.

Aliases
-------

### Build

  * `pacb` build package in the current directory, cleanup, and install.

### Install

  * `paci` install, sync, and upgrade packages.
  * `pacu` install, sync, and upgrade packages (forcibly refresh package list).
  * `pacU` install packages from pkg file.
  * `pacd` install all packages in current directory.

### Remove

  * `pacr` remove package and unneeded dependencies.
  * `pacrm` remove package, unneded dependencies, and configuration files.

### Query

  * `pacq` query package information from remote repository
  * `pacQ` query package information from local repository

### Search

  * `pacs` search for package in the remote repository
  * `pacS` search for package in the local repository

### Orphans

  * `pacol` list orphan packages
  * `pacor` remove all orphan packages

### Ownership

  * `pacown` list all files provided by a given package
  * `pacblame` show package(s) that own a specified file

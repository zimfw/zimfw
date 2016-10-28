#
# AUR aliases
#

# download and build AUR package
aurb() {
  git clone https://aur.archlinux.org/${1}.git && cd ${1} && makepkg --clean --install --syncdeps
}

# only download aur package; do not build
aurd() {
  git clone https://aur.archlinux.org/${1}.git 
}

# remove old package, rebuild, and install.
#NOTE: this is will remove any unstashed/uncommitted changes.
#      due to how makepkg will update the PKGBUILD, a git pull alone will not suffice.
auru() {
  git reset HEAD --hard && git pull && makepkg --clean --force --install --syncdeps --cleanbuild
}

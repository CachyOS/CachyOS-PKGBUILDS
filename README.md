<div align="center">
  <img src="https://github.com/CachyOS/calamares-config/blob/grub-3.2/etc/calamares/branding/cachyos/logo.png" width="64" alt="CachyOS logo"></img>
  <br/>
  <h1 align="center">CachyOS</h1>
</div>

# CachyOS PKGBUILDS

[CachyOS](https://cachyos.org/) PKGBUILDS is a collection of [PKGBUILD](https://wiki.archlinux.org/index.php/PKGBUILD) scripts for building and installing packages on any Arch Linux-based operating system.

## Prerequisites

In order to use these PKGBUILD scripts, you will need to have the following tools and libraries installed on your system:

- [Git](https://git-scm.com/)
- [make](https://www.gnu.org/software/make/)
- [gcc](https://gcc.gnu.org/)
- [binutils](https://www.gnu.org/software/binutils/)
- [fakeroot](https://wiki.archlinux.org/index.php/Fakeroot)

## Usage

To build and install a package using one of the PKGBUILD scripts in this repository, follow these steps:

1. Clone this repository: `git clone https://github.com/CachyOS/cachyos-pkgbuilds.git`
2. Navigate to the directory of the PKGBUILD script you want to use: `cd cachyos-pkgbuilds/<package>`
3. Build the package: `makepkg -si`
4. Install the package: `sudo pacman -U <packagename>.pkg.tar.zst`

## Contributions

If you would like to contribute to CachyOS PKGBUILDS, please fork this repository and submit a pull request with your changes. Please be sure to follow the [ArchLinux Packaging Guidelines](https://wiki.archlinux.org/title/Arch_package_guidelines) when creating or modifying PKGBUILD scripts.

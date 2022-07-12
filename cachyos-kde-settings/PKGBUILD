# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-kde-settings
pkgdesc='CachyOS KDE settings'
pkgver=1.23
pkgrel=2
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('GPL')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('6c5cb4139991dd1b42a02acb7ff86ba268b44e5a5c79875f144a67a5a7c33d1af2424035f784e9d39bb61a6b0d38b8761600251f30c9b52ec243b0194286d1cd')
depends=('cachyos-zsh-config'
         'cachyos-fish-config'
         'lightlyshaders-git'
         'lightly-git'
         'qt5ct'
         'nerd-fonts-fantasque-sans-mono'
         'noto-fonts'
         'ttf-fira-sans'
         'plasma5-applets-eventcalendar'
         'plasma5-applets-netspeed'
         'plasma5-applets-window-appmenu'
         'plasma5-applets-window-buttons'
         'plasma5-applets-window-title'
         'kwin-scripts-forceblur'
         'ksysguard'
         'char-white'
         'capitaine-cursors'
         'cachyos-nord-kde-theme-git'
         'cachyos-wallpapers'
         'cachyos-nord-gtk-theme-git')
install=$pkgname.install
provides=('cachyos-desktop-settings')
conflicts=('cachyos-desktop-settings')

package() {
    install -d $pkgdir/etc
    cp -rf $srcdir/$pkgname-$pkgver/etc $pkgdir
    install -d $pkgdir/usr
    cp -rf $srcdir/$pkgname-$pkgver/usr $pkgdir
}

# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-gnome-settings
pkgdesc='CachyOS GNOME settings'
pkgver=1.1.0
pkgrel=1
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('GPL')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('daa77a0a31ac24be0f1e256684cb78568068777889f22388dc7732ecd416211e5e4ab08b875494a1d0d5a8834a75decc9090208f04f55d38398d79d8d7eed5f9')
depends=('kvantum-qt5'
         'qt5ct'
         'gnome-autoar'
         'gnome-bluetooth-3.0'
         'gnome-calculator'
         'gnome-color-manager'
         'gnome-control-center'
         'gnome-desktop'
         'gnome-desktop-4'
         'gnome-desktop-common'
         'gnome-disk-utility'
         'gnome-firmware'
         'gnome-keyring'
         'gnome-online-accounts'
         'gnome-screenshot'
         'gnome-session'
         'gnome-settings-daemon'
         'gnome-shell'
         'gnome-system-monitor'
         'gnome-terminal'
         'gnome-themes-extra'
         'gnome-tweaks'
         'capitaine-cursors'
         'cachyos-wallpapers'
         'gnome-backgrounds'
         'kvantum-theme-libadwaita-git')
install=$pkgname.install
provides=('cachyos-desktop-settings')
conflicts=('cachyos-desktop-settings')

package() {
    install -d $pkgdir/etc
    cp -rf $srcdir/$pkgname-$pkgver/etc $pkgdir
}

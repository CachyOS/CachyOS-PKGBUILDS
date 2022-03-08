# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-kde-settings
pkgdesc='CachyOS KDE settings'
pkgver=1.0.0
pkgrel=1
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('GPL')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('3c8d3e5bb0220a7e352673e3166305f934dee54fc6b4afd3271bca1c862494fd884983627099916d20e282e58142b1a3925ecb577b383d1f88f7d05143577046')
depends=('cachyos-zsh-config'
         'lightly-git'
         'kvantum-qt5'
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
         'cachyos-emerald-kde-theme-git'
         'nordic-theme-git')
install=$pkgname.install
provides=('cachyos-desktop-settings')
conflicts=('cachyos-desktop-settings')

package() {
    install -d $pkgdir/etc
    cp -rf $srcdir/$pkgname-$pkgver/etc $pkgdir
    install -d $pkgdir/usr
    cp -rf $srcdir/$pkgname-$pkgver/usr $pkgdir
}

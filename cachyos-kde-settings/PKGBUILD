# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-kde-settings
pkgdesc='CachyOS KDE settings'
pkgver=1.0.0
pkgrel=2
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('GPL')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('f6a1a83d5f7ac43fc0f26d3fa479064497b5fb124b582d1d65fc55b896f8b1f9aa7b2661e6432a45829640e063873169c72ae04e7bbd7a02c7f3a829426394f0')
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
}

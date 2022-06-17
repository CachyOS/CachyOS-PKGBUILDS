# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-kde-settings
pkgdesc='CachyOS KDE settings'
pkgver=1.0.7
pkgrel=2
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('GPL')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('dc287adc38534b271ae232c97e71289cecf2db0057f835b7ad07edd4e0cd6b43516264e949e2f38d3789ad0589a1160b238600a4c3422a2a7dc08f66f85d7ffc')
depends=('cachyos-zsh-config'
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
}

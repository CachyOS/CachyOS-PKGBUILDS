# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-kofuku
pkgver=1.0.0
pkgrel=1
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('MIT')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('1be307d72ffcce28a7e378b15296184df554345562770f2c81b0e8de8891ab32a202c355031c737c1340f91df2aba9d04503f435075bc3f23910dfaf60eebcb4')
pkgdesc='Kofuku settings'
depends=('cachyos-zsh-config'
        'nerd-fonts-fantasque-sans-mono'
        'rofi'
        'rxvt-unicode'
        'lightdm-webkit2-greeter'
        'cachyos-picom-config'
        'polybar'
        'sxhkd'
        'deadd-notification-center'
        'ttf-fira-sans')
install=$pkgname.install
provides=('cachyos-desktop-settings')
conflicts=('cachyos-desktop-settings' 'lightdm-webkit2-theme-glorious')

package() {
    install -d $pkgdir/etc
    cp -rf $srcdir/$pkgname-$pkgver/etc $pkgdir
    install -d $pkgdir/usr
    cp -rf $srcdir/$pkgname-$pkgver/usr $pkgdir
}

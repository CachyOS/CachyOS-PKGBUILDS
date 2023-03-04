# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-hyprland-settings
pkgdesc='CachyOS Hyprland settings'
pkgver=1.0.0
pkgrel=3
arch=('any')
url="https://github.com/cachyos/$pkgname"
license=('GPL')
makedepends=('coreutils')
source=("$pkgname-$pkgver.tar.gz::$url/archive/$pkgver.tar.gz")
sha512sums=('54aed6670ea3e8125ea3a975e1b348a4f9f89d6a59499e73382cc9ccd1cb4c5b87da58e78187f879763693863d055def317fe367ded17610b8bcfbf7292e269a')
depends=('cachyos-fish-config'
         'ttf-fantasque-nerd'
         'ttf-font-awesome'
         'otf-font-awesome'
         'awesome-terminal-fonts'
         'noto-fonts'
         'noto-fonts-emoji'
         'ttf-fira-sans'
         'ttf-hack'
         'kvantum-qt5'
         'qt5ct'
         'swaybg'
         'swaylock-effects-git'
         'swaylock-fancy-git'
         'hyprland-git'
         'waybar-hyprland-git'
         'xdg-desktop-portal-hyprland-git'
         'grimblast-git'
         'slurp'
         'mako'
         'wob'
         'wl-clipboard'
         'polkit-kde-agent'
         'bemenu'
         'bemenu-wayland'
         'xorg-xwayland'
         'capitaine-cursors'
         'cachyos-wallpapers'
         'kvantum-theme-nordic-git'
         'cachyos-nord-gtk-theme-git')
provides=('cachyos-desktop-settings')
conflicts=('cachyos-desktop-settings')

package() {
    install -d $pkgdir/etc
    cp -rf $srcdir/$pkgname-$pkgver/etc $pkgdir
}

# Maintainer: Vladislav Nepogodin <nepogodin.vlad@gmail.com>

pkgname=cachyos-packageinstaller
pkgver=1.0.7
pkgrel=1
pkgdesc="Simple Software Application Package Installer for CachyOS which helps setting up & installing applications"
arch=(aarch64 x86_64 x86_64_v3)
url="https://github.com/cachyos/packageinstaller"
license=(GPLv3)
depends=('qt5-base' 'polkit')
makedepends=('cmake' 'ninja' 'git' 'polkit-qt5' 'qt5-tools')
groups=('cachyos')
source=("packageinstaller-$pkgver.tar.gz::$url/archive/v$pkgver.tar.gz")
sha256sums=('a6241c1b5f5a1c3d63768818bd4301790973463345b66f3386d2382e42f764da')
provides=('cachyos-packageinstaller')
conflicts=('cachyos-packageinstaller')
options=(strip)

build() {
  cd ${srcdir}/packageinstaller-${pkgver}

  _cpuCount=$(grep -c -w ^processor /proc/cpuinfo)

  cmake -S . -Bbuild \
        -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib
  cmake --build build --parallel $_cpuCount
}

package() {
  cd ${srcdir}/packageinstaller-${pkgver}
  DESTDIR="${pkgdir}" cmake --build build --target install

  install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}

# vim:set sw=2 sts=2 et:

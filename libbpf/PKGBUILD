# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
# Contributor:  Adrian Bacircea <adrian.bacircea@gmail.com>

pkgname=libbpf
pkgver=1.5.0
pkgrel=1
pkgdesc='Library for loading eBPF programs and reading and manipulating eBPF objects from user-space'
url='https://github.com/libbpf/libbpf'
arch=(x86_64)
license=(LGPL-2.1-or-later)
depends=(
  glibc
  libelf
  linux-api-headers
  zlib
)
makedepends=(
  rsync
)
provides=(libbpf.so)
source=(https://github.com/libbpf/libbpf/archive/v${pkgver}/${pkgname}-${pkgver}.tar.gz)
sha512sums=('0cc25addcf5fcee0537d598037feab4bc73a513e6025d8f559bed58fe8850a10fcfeefd1a9dafc5e0bac6202d445944b12811cb7254b9b3be4dd3d2cc1e9419b')
b2sums=('fd9bbf7689632c6f3fc18705bf1cfb5ba8abca632f6da1264692f0b6ff0e5887fb88697dd4418cc9a451df3421015f4c8de5162c1b8a40594af050dca3442669')

build() {
  cd ${pkgname}-${pkgver}
  make -C src
}

package() {
  cd ${pkgname}-${pkgver}
  make -C src DESTDIR="${pkgdir}" LIBSUBDIR=lib install install_headers
  install -Dm 644 LICENSE* -t "${pkgdir}/usr/share/licenses/${pkgname}"
  install -Dm 644 README.md -t "${pkgdir}/usr/share/doc/${pkgname}"
}

# vim: ts=2 sw=2 et:

# Maintainer: Pierre Schmitz <pierre@archlinux.de>
# Maintainer: Bartłomiej Piotrowski <bpiotrowski@archlinux.org>

pkgname=archlinux-keyring
pkgver=20250807.1
pkgrel=1
pkgdesc='Arch Linux PGP keyring'
arch=('any')
url='https://gitlab.archlinux.org/archlinux/archlinux-keyring/'
license=('GPL-3.0-or-later')
install=$pkgname.install
depends=('pacman')
makedepends=('git' 'python' 'sequoia-sq' 'pkgconf' 'systemd')
checkdepends=('python-coverage' 'python-pytest')
source=("archlinux-keyring::git+https://gitlab.archlinux.org/archlinux/archlinux-keyring.git#tag=${pkgver}?signed")
sha256sums=('bf610cf35ce803b2de7dd971797c5663d7f3ddeaaf5549fa1c2f7537447d5393')
validpgpkeys=('02FD1C7A934E614545849F19A6234074498E9CEE'  # Christian Hesse <eworm@archlinux.org>
              'C7E7849466FE2358343588377258734B41C31549'  # David Runge <dvzrv@archlinux.org>
              '4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC'  # Pierre Schmitz <pierre@archlinux.org>
              'CFA6AF15E5C74149FC1D8C086D1655C14CE1C13E'  # Florian Pritz <bluewind@archlinux.org>
              'ECCAC84C1BA08A6CC8E63FBBF22FB1D78A77AEAB'  # Giancarlo Razzolini <grazzolini@archlinux.org>
              'E240B57E2C4630BA768E2F26FC1B547C8D8172C8'  # Levente Polyak <anthraxx@archlinux.org>
              'C100346676634E80C940FB9E9C02FF419FECBE16') # Morten Linderud <foxboron@archlinux.org>

build() {
  cd archlinux-keyring/

  make build
}

check() {
  cd archlinux-keyring/

  make check
}

package() {
  cd archlinux-keyring/

  make PREFIX='/usr' DESTDIR="${pkgdir}" install
}

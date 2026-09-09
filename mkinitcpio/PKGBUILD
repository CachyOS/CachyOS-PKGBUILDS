# Maintainer: Giancarlo Razzolini <grazzolini@archlinux.org>
# Maintainer: Lukas Fleischer <lfleischer@archlinux.org>
# Contributor: Morten Linderud <foxboron@archlinux.org>
# Contributor: Dave Reisner <dreisner@archlinux.org>
# Contributor: Thomas Bächler <thomas@archlinux.org>

pkgname=mkinitcpio
pkgver=42
pkgrel=1
pkgdesc="Modular initramfs image creation utility"
arch=('any')
url='https://gitlab.archlinux.org/archlinux/mkinitcpio/mkinitcpio'
license=('GPL-2.0-only')
depends=('awk' 'mkinitcpio-busybox' 'kmod' 'util-linux' 'libarchive' 'coreutils'
         'bash' 'binutils' 'diffutils' 'findutils' 'grep' 'gzip' 'filesystem' 'zstd' 'systemd')
checkdepends=('bats' 'bats-assert' 'lzop')
makedepends=('asciidoctor' 'git' 'meson')
optdepends=('xz: Use lzma or xz compression for the initramfs image'
            'bzip2: Use bzip2 compression for the initramfs image'
            'lzop: Use lzo compression for the initramfs image'
            'lz4: Use lz4 compression for the initramfs image'
            'mkinitcpio-nfs-utils: Support for root filesystem on NFS'
            'systemd-ukify: alternative UKI generator')
provides=('initramfs')
backup=('etc/mkinitcpio.conf')
source=("git+$url.git#tag=v${pkgver}?signed")
sha512sums=('bb8b7b2153c6c73c3e8829b0d2beed9c9096830cf21ec9f97fc993384f0e174e66c412ced96589fcf8244e17b8427db346310d50ab8335fb489d7842ba7fe0c9')
b2sums=('fad80b4d2abe0eecb001b6369103a6ed079c6dbb724821498a635ce51cf4731a46831fe4aaf05e860782ab0a69ad0ba09e11f314a0a1ac452d1b9001df38cd4b')
validpgpkeys=('ECCAC84C1BA08A6CC8E63FBBF22FB1D78A77AEAB'    # Giancarlo Razzolini
              'BB8E6F1B81CF0BB301D74D1CBF425A01E68B38EF')   # nl6720

build(){
	arch-meson -Dsystemd_hooks=true "$pkgname" build
	meson compile -C build
}

check() {
	meson test -C build
}

package() {
	meson install -C build --destdir "$pkgdir"
}

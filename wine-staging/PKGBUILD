# Maintainer: Felix Yan <felixonmars@archlinux.org>
# Maintainer: Peter Jung <ptr1337@archlinux.org>
# Contributor: Sven-Hendrik Haase <sh@lutzhaase.com>
# Contributor: Jan "heftig" Steffens <jan.steffens@gmail.com>
# Contributor: Eduardo Romero <eduardo@archlinux.org>
# Contributor: Giovanni Scafora <giovanni@archlinux.org>

pkgname=wine-staging
pkgver=10.3
pkgrel=1

_pkgbasever=${pkgver/rc/-rc}
_winever=$_pkgbasever
#_winever=${_pkgbasever%.*}

source=("git+https://gitlab.winehq.org/wine/wine.git?signed#tag=wine-$_pkgbasever"
        "git+https://gitlab.winehq.org/wine/wine-staging.git#tag=v$_pkgbasever"
        30-win32-aliases.conf
        wine-binfmt.conf)
sha512sums=('d3cdc9c798d7c3ebffc73de8000e7c79260b8ba3019b41bebed8b329293ed4283110b3404a7d71a8204416fda2045bb2778d5f260f1139fb991ea798a5166e27'
            '4fb3757b5b129db1913299283dc7819ab50531e0c56afd9a63eb09785cd8a0b5739d51c2bbff98140c9def78f564d57053ac9219743d613fce9d8c965225ca8d'
            '6e54ece7ec7022b3c9d94ad64bdf1017338da16c618966e8baf398e6f18f80f7b0576edf1d1da47ed77b96d577e4cbb2bb0156b0b11c183a0accf22654b0a2bb'
            'bdde7ae015d8a98ba55e84b86dc05aca1d4f8de85be7e4bd6187054bfe4ac83b5a20538945b63fb073caab78022141e9545685e4e3698c97ff173cf30859e285')
validpgpkeys=(5AC1A08B03BD7A313E0A955AF5E6E9EEB9461DD7
              DA23579A74D4AD9AF9D3F945CEFAC8EAAF17519D)

pkgdesc="A compatibility layer for running Windows programs - Staging branch"
url="https://www.wine-staging.com"
arch=(x86_64)
options=(staticlibs !lto)
license=(LGPL-2.1-or-later)
depends=(
  attr            lib32-attr
  desktop-file-utils
  fontconfig      lib32-fontconfig
  freetype2       lib32-freetype2
  gcc-libs        lib32-gcc-libs
  gettext         lib32-gettext
  libpcap         lib32-libpcap
  libxcursor      lib32-libxcursor
  libxi           lib32-libxi
  libxrandr       lib32-libxrandr
)
makedepends=(autoconf bison perl flex mingw-w64-gcc
  git
  alsa-lib              lib32-alsa-lib
  ffmpeg
  giflib                lib32-giflib
  gnutls                lib32-gnutls
  gst-plugins-base-libs lib32-gst-plugins-base-libs
  gtk3                  lib32-gtk3
  libcups               lib32-libcups
  libgphoto2
  libpulse              lib32-libpulse
  libva                 lib32-libva
  libxcomposite         lib32-libxcomposite
  libxinerama           lib32-libxinerama
  libxxf86vm            lib32-libxxf86vm
  mesa                  lib32-mesa
  mesa-libgl            lib32-mesa-libgl
  opencl-headers
  opencl-icd-loader     lib32-opencl-icd-loader
  samba
  sane
  sdl2                  lib32-sdl2
  v4l-utils             lib32-v4l-utils
  vulkan-icd-loader     lib32-vulkan-icd-loader
)
optdepends=(
  alsa-lib              lib32-alsa-lib
  alsa-plugins          lib32-alsa-plugins
  cups                  lib32-libcups
  dosbox
  ffmpeg
  giflib                lib32-giflib
  gnutls                lib32-gnutls
  gst-plugins-base-libs lib32-gst-plugins-base-libs
  gtk3                  lib32-gtk3
  libgphoto2
  libpulse              lib32-libpulse
  libva                 lib32-libva
  libxcomposite         lib32-libxcomposite
  libxinerama           lib32-libxinerama
  opencl-icd-loader     lib32-opencl-icd-loader
  samba
  sane
  sdl2                  lib32-sdl2
  v4l-utils             lib32-v4l-utils
  vulkan-icd-loader     lib32-vulkan-icd-loader
  wine-gecko
  wine-mono
)

provides=("wine=$pkgver")
conflicts=('wine')
install=wine.install

prepare() {
  # Get rid of old build dirs
  rm -rf $pkgname-{32,64}-build
  mkdir $pkgname-{32,64}-build

  cd wine
  # apply wine-staging patchset
  ../wine-staging/staging/patchinstall.py --backend=git-apply --all
}

build() {
  # Doesn't compile without remove these flags as of 4.10
  # incompatible-pointer-types: https://bugs.gentoo.org/919758
  export CFLAGS="$CFLAGS -ffat-lto-objects -Wno-error=incompatible-pointer-types"

  # Apply flags for cross-compilation
  export CROSSCFLAGS="-O2 -pipe"
  export CROSSCXXFLAGS="-O2 -pipe"
  export CROSSLDFLAGS="-Wl,-O1"

  echo "Building Wine-64..."
  cd "$srcdir/$pkgname-64-build"
  ../wine/configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --with-x \
    --with-wayland \
    --with-gstreamer \
    --with-xattr \
    --enable-win64

  make

  echo "Building Wine-32..."
  export PKG_CONFIG_PATH="/usr/lib32/pkgconfig"
  cd "$srcdir/$pkgname-32-build"
  ../wine/configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --with-x \
    --with-wayland \
    --with-gstreamer \
    --with-xattr \
    --with-wine64="$srcdir/$pkgname-64-build"

  make
}

package() {
  echo "Packaging Wine-32..."
  cd "$srcdir/$pkgname-32-build"
  make prefix="$pkgdir/usr" \
    libdir="$pkgdir/usr/lib" \
    dlldir="$pkgdir/usr/lib/wine" install

  echo "Packaging Wine-64..."
  cd "$srcdir/$pkgname-64-build"
  make prefix="$pkgdir/usr" \
    libdir="$pkgdir/usr/lib" \
    dlldir="$pkgdir/usr/lib/wine" install

  # Font aliasing settings for Win32 applications
  install -d "$pkgdir"/usr/share/fontconfig/conf.{avail,default}
  install -m644 "$srcdir/30-win32-aliases.conf" "$pkgdir/usr/share/fontconfig/conf.avail"
  ln -s ../conf.avail/30-win32-aliases.conf "$pkgdir/usr/share/fontconfig/conf.default/30-win32-aliases.conf"
  install -Dm 644 "$srcdir/wine-binfmt.conf" "$pkgdir/usr/lib/binfmt.d/wine.conf"

  i686-w64-mingw32-strip --strip-unneeded "$pkgdir"/usr/lib/wine/i386-windows/*.dll
  x86_64-w64-mingw32-strip --strip-unneeded "$pkgdir"/usr/lib/wine/x86_64-windows/*.dll
}

# vim:set ts=8 sts=2 sw=2 et:

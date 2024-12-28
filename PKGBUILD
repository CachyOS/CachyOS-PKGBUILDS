# Maintainer: Jan Alexander Steffens (heftig) <heftig@archlinux.org>
# Contributor: Jan de Groot <jgc@archlinux.org>
# Contributor: Joey Riches (joebonrichie) <josephriches@gmail.com>

pkgbase=pango
pkgname=(
  pango
  pango-docs
)
pkgver=1.54.0
pkgrel=2
epoch=1
pkgdesc="A library for layout and rendering of text"
url="https://www.pango.org/"
arch=(x86_64)
license=(LGPL-2.1-or-later)
depends=(
  cairo
  fontconfig
  freetype2
  fribidi
  glib2
  glibc
  harfbuzz
  libsysprof-capture
  libthai
  libx11
  libxft
  libxrender
)
makedepends=(
  gi-docgen
  git
  glib2-devel
  gobject-introspection
  help2man
  meson
)
source=("git+https://gitlab.gnome.org/GNOME/pango.git#tag=$pkgver")
b2sums=('365a31b09d9e11eda15f79339fde4cd635cd4f24c7b80f883020c95ee27f7d4074495e74531c727ea1b4d4f89e32641003758e388c54a5473be00527526645e5')

prepare() {
  cd pango
}

build() {
  local meson_options=(
    -D documentation=true
    -D sysprof=enabled
  )

  export PROFILE_DATA="${srcdir}/PGO"
  # O3 causes a performance regression in tested benchmarks, ensure we use O2
  export CFLAGS="${CFLAGS} -fprofile-generate -fprofile-update=atomic -fprofile-dir=$PROFILE_DATA -O2"

  arch-meson pango build "${meson_options[@]}"
  meson compile -C build

  meson test -C build
  rm -fr build

  export CFLAGS="${CFLAGS/-fprofile-generate/}"
  export CFLAGS="${CFLAGS/-fprofile-update=atomic/}"
  export CFLAGS="${CFLAGS} -fprofile-use"

  arch-meson pango build "${meson_options[@]}"
  meson compile -C build
}

# not running checks: validation breaks when deps
# (especially harfbuzz) don't match upstream CI

package_pango() {
  provides=(libpango{,cairo,ft2,xft}-1.0.so)

  meson install -C build --destdir "$pkgdir"

  mkdir -p doc/usr/share
  mv {"$pkgdir",doc}/usr/share/doc
}

package_pango-docs() {
  pkgdesc+=" (documentation)"
  depends=()

  mv doc/* "$pkgdir"
}

# vim:set sw=2 sts=-1 et:

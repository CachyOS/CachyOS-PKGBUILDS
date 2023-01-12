pkgname=systemd-boot-manager
pkgver=7
pkgrel=1
pkgdesc='A simple tool to maintain systemd-boot & systemd-boot entries for CachyOS'
arch=(any)
url="https://github.com/CachyOS/CachyOS-PKGBUILDS/tree/master/$pkgname"
license=(GPL2)
backup=('etc/sdboot-manage.conf')
depends=(systemd
  findutils
  grep
  gawk)

source=(
  $url/sdboot-manage
  $url/sdboot-manage.conf
  $url/sdboot-kernel-update.hook
  $url/sdboot-kernel-remove.hook
  $url/sdboot-systemd-update.hook
)

sha512sums=('03d05296db3ae910f3b58ad5c7dc1a0336def4211415333561920724b903d0ef0e71a2e4874987baad54701cea908661c5e62ce984d4eaeb967d966d081b0d85'
            '6e11502065a6ea34a2c71b9464593c041d2c85893ffecd7d8e1ec99fdd4280ecc3fa8592ed1c99bb9375e69847e565d7e4451c7319f966f4bd41efa84a1697dd'
            '047da99a32b3cf1d9ff52ff347a0a8119f7c02a947d45c913c62d4c960d69aebcc240c1a466780bbcea08903361d8f33096d679e8aaac81d8a1f0c9fdf48f442'
            '4ff08aa5d4603d699a6d5df96bc19ef15959418b41bab62b4425e97c263f6561f8fcb7cf4b06cb2a1153e0c842cc6fb03dd2f50ff24ab2489b0f129b91febc71'
            'ebd0c79def6f2d77b9eac63ca41460db5670220dd9ba033bd0c24017abc7f71da2250907f76cac0cc9cf10e219ef518b916aa547fafbba4715be4985cc278c50')
package() {
  install -D -m755 "sdboot-manage" "${pkgdir}/usr/bin/sdboot-manage"
  install -D -m644 "sdboot-manage.conf" "${pkgdir}/etc/sdboot-manage.conf"
  install -D -m644 "sdboot-kernel-update.hook" "${pkgdir}/usr/share/libalpm/hooks/sdboot-kernel-update.hook"
  install -D -m644 "sdboot-kernel-remove.hook" "${pkgdir}/usr/share/libalpm/hooks/sdboot-kernel-remove.hook"
  install -D -m644 "sdboot-systemd-update.hook" "${pkgdir}/usr/share/libalpm/hooks/sdboot-systemd-update.hook"
}

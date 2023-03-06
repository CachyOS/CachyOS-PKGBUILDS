pkgname=systemd-boot-manager
pkgver=7
pkgrel=3
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

sha512sums=('9c9b8d540b8655431b516314adab85bece1ae2b91e20a85ddf210832d60789af9adb1eaadf56889ca09d7beabd508ea6d478f9f625c7fc5884c8174a32b63e38'
            '0ccb48c39669531f6333d0fd3e44c8c7c2d871daec090936da4c763c6d94c11171825136b8d3c2af7d2f2bc3b4ddafd7a01bf55dbdfc46c53b9014e73a497b31'
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

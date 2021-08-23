pkgname=systemd-boot-manager
pkgver=1
pkgrel=1
pkgdesc='A simple tool to maintain systemd-boot & systemd-boot entries for CachyOS'
arch=(any)
url="https://gitlab.com/cachyos/PKGBUILDS/-/raw/master/$pkgname"
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

sha512sums=('f8799aa997c7d0573d2303aa200415e35b98fa9f2d6d07754d479b66dc7b0db931cfa135983f4287b9dd4b6300699cea66ffea81adf84f3fc7ea70bddc387df8'
            '2656e5a10222946395835413a820c6cf42985e8a3483cc160943c4341f20ff6c59ce91f07b31b1073e116dbd9aacf4418e91e9b6ae573472af59a7318cf68506'
            '047da99a32b3cf1d9ff52ff347a0a8119f7c02a947d45c913c62d4c960d69aebcc240c1a466780bbcea08903361d8f33096d679e8aaac81d8a1f0c9fdf48f442'
            '4ff08aa5d4603d699a6d5df96bc19ef15959418b41bab62b4425e97c263f6561f8fcb7cf4b06cb2a1153e0c842cc6fb03dd2f50ff24ab2489b0f129b91febc71'
            'ebd0c79def6f2d77b9eac63ca41460db5670220dd9ba033bd0c24017abc7f71da2250907f76cac0cc9cf10e219ef518b916aa547fafbba4715be4985cc278c50')
package()
{
    install -D -m755 "${srcdir}/${pkgname}/sdboot-manage" "${pkgdir}/usr/bin/sdboot-manage"
    install -D -m644 "${srcdir}/${pkgname}/sdboot-manage.conf" "${pkgdir}/etc/sdboot-manage.conf"
    install -D -m644 "${srcdir}/${pkgname}/sdboot-kernel-update.hook" "${pkgdir}/usr/share/libalpm/hooks/sdboot-kernel-update.hook"
    install -D -m644 "${srcdir}/${pkgname}/sdboot-kernel-remove.hook" "${pkgdir}/usr/share/libalpm/hooks/sdboot-kernel-remove.hook"
    install -D -m644 "${srcdir}/${pkgname}/sdboot-systemd-update.hook" "${pkgdir}/usr/share/libalpm/hooks/sdboot-systemd-update.hook"
}

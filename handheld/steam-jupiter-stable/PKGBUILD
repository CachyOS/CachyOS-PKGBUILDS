# Maintainer: John Schoenick <johns@valvesoftware.com>
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
# Maintainer: Giancarlo Razzolini <grazzolini@archlinux.org>
# Contributor: Daniel Wallace <danielwallace at gtmanfred dot com>
# Contributor: K900 <k0009000@gmail.com>

_basename=steam
pkgname=steam-jupiter-stable
pkgver=1.0.0.85
pkgrel=9
pkgdesc="Valve's digital software delivery system - Jupiter bootstrapped packaging"
url='https://steampowered.com/'
arch=('x86_64')
license=('custom')
depends=(
  bash
  desktop-file-utils
  diffutils
  hicolor-icon-theme
  curl
  dbus
  freetype2
  gdk-pixbuf2
  ttf-font
  zenity
  lsb-release
  nss
  usbutils
  xorg-xrandr
  vulkan-driver
  vulkan-icd-loader
  lsof
  'python>=3.13'
  'python<3.14'
  xdg-user-dirs
  glibc
  libxcrypt
  libxcrypt-compat
  gcc-libs
)
depends_x86_64=(
  # Holo
  # https://gitlab.archlinux.org/archlinux/packaging/packages/steam/-/issues/9
  lib32-pipewire
  # https://gitlab.archlinux.org/archlinux/packaging/packages/steam/-/issues/6
  lib32-fontconfig
  # https://gitlab.archlinux.org/archlinux/packaging/packages/steam/-/issues/10
  lib32-systemd
  lib32-libxinerama
  # https://gitlab.archlinux.org/archlinux/packaging/packages/steam/-/issues/11
  lib32-libnm
  lib32-libva

  lib32-glibc
  lib32-libxcrypt
  lib32-libxcrypt-compat
  lib32-libgl
  lib32-gcc-libs
  lib32-libx11
  lib32-libxss
  lib32-alsa-plugins
  lib32-libgpg-error
  lib32-nss
  lib32-vulkan-driver
  lib32-vulkan-icd-loader
)
provides=('steam')
conflicts=('steam')

# Jupiter: Drops native-runtime patches
# optdepends=('steam-native-runtime: steam native runtime support')
optdepends=('lib32-libnm: integration with networkmanager')

# Jupiter: Including fully bootstrapped steam image on expected branch
_fat_bootstrap=steam_jupiter_stable_bootstrapped_20251031.0.tar.xz
noextract=("$_fat_bootstrap")
source=(https://repo.steampowered.com/${_basename}/archive/beta/${_basename}_${pkgver}{.tar.gz,.dsc}
        https://steamdeck-packages.steamos.cloud/misc/steam-snapshots/"$_fat_bootstrap"
        70-steam-jupiter-input.rules
        70-steam-jupiter-leds.rules
        99-power-wakeup.rules
        steam-jupiter.sh
        steam-runtime.sh
        # Remove when we go to 1.0.0.81 (https://gitlab.steamos.cloud/holo-team/tasks/-/issues/1398)
        bin_steam.sh
        )
sha512sums=('81d404fcbd516fa1d984a991be3530855c0ded826ea8aca68c8cb5492e95d3d430cd7c556a9997a7c0780055a810239322181b1785e78f8d8fabe01c39fee2f7'
            'e3722d006485249fc91113feee0df018d341dc8d7327199a9161022c84b04ca5faa2be36268d50ae0bc29b6fd6063fe2b69a29a354adb32dd6b75d78dc7f9702'
            'a013473d28a9d10a865b543ee1c42fa514c4af383b63f7dbf8e38d18e358ebdbc247caff1e39cc372a71b05fdd506f2356e1af0c5404a95f6615191d994e0fbf'
            '15cf483d9febd72cd702c306818a2af53131953cedd53750df50dceca427d2dcf5ff6e40d1b5cac7676653d3f920f420b897d456d239fcc62dc2c617d4c0291f'
            'a7dbf511deccdd66b742042269ed8ff09c416e79b2a297065e95d8068b1cddd7475d0955309bfbc1a625eb71a919b6e627d9df07cb04aa8b2c38e64b887f59db'
            '34f667354b8e0b1bd28c4c4abd3072fa36d3e470a5d1dcab5461ae8f7025f3862079e70396afe561af0d2d52ac4191336a3c595427e20429ca97a33c1eae0b2d'
            '2bb741aa1698f354ba98d48ceaaf0eb1dd76b4c08078a51e34ab4b94a8129105c89d17fa7786499e6337562fef5c2d3fe9633ec490b31b8ddb9afc2afec9af7f'
            '5e75c019e9fe8c67d686c4e3343dac1180a69a4bdb7d39b333415c63201eef9b98da5619dbf6fd8daa6884e65bc7f8afc9e52778682425e5a75987d527eae6f0'
            '47e2b8d2ecdb40ef2d5555e31122f1e863920998089f9dc7ce58b112ba72df6745ae30927ef158cfa735faad41b82bd6cdf25e9c69d7e780374648f57bdc3b72')
b2sums=('6cc699e7b740693529845ef76d39570a977716735da46e21b681629aebf3e5ee80b09a3b47b1c84debb066ca43456f1c78509de7ddfe8e35df21903cceebde4f'
        '833edc4b6b8aa32861fb6caccdc4f7441a0462600315b68eae0bbbebf7c94cc64a8be61ce2e30842ea2f354ac0630898b7829d0d9eafd97eb7b621a72befb897'
        '05d91f055a0ce36737d065705d4817d57381a6e28a055cc505b4ddd3e2546e4bee8fa5e0d0c17df45bbb3caac0e8fd57aed7277f8c43b0f5a40c0feb83218c81'
        '8d8df71b056f595b3e5fb47118b067a74e9066962bf0d181e15aea237b586cc1ee146d682a76c345cf41ed08fa49ac4b80b9f5e8a4bdac8176d6b5e1220df779'
        '9be80bdcadeaa7beb7beec83dad1aad6b031b62392077dc61b638cb5e679478e78e09c5ada81101215796fdbb077259cf18a7977b924f4f90d7953967545b2aa'
        '5165ac5f212abb2bcf31fdcb492c06a49772f9203bdb2e6c66d4ecc620b863f34405d228ffa314935d00b08f7539e5007ed37af90d119029075b1d7a4d02bc62'
        '26b6a0c04f414c623dcace7ac6d5e0ed398bd2fe2f7ab2b5408f6a9b0d2be66bbddaaded3b5b637edaf23697a718eb0cedd77294c92e6c8f3d2ced2f84a2f3b8'
        'c6bac99336b7c30fec7cdbaf9e949555c687dd9dff50bcae136134d6314f4b841f5fc66ddb2caac1b003690b926fd4afbdc11da143b4674db4b75f27709fdd23'
        'fb6df965a9e537835262a2e0e722469799d72b2a7afa1793efa69685a60dfb8624e25f9dced7dcde2549eb4c2a37fc588593e6182c83a77956e4263e0c87853e')

validpgpkeys=('BA1816EF8E75005FCF5E27A1F24AEA9FB05498B7') # linux@steampowered.com

package() {
  cd ${_basename}-launcher
  make DESTDIR="${pkgdir}" install

  install -Dm 755 "${srcdir}/steam-runtime.sh" "${pkgdir}/usr/bin/steam-runtime"
  install -d "${pkgdir}/usr/lib/steam"
  mv "${pkgdir}/usr/bin/steam" "${pkgdir}/usr/lib/steam/steam"
  ln -sf /usr/bin/steam-runtime "${pkgdir}/usr/bin/steam"

  install -Dm 644 COPYING steam_subscriber_agreement.txt -t "${pkgdir}/usr/share/licenses/${pkgname}"
  install -Dm 644 debian/changelog -t "${pkgdir}/usr/share/doc/${pkgname}"

  # blank steamdeps because apt-get
  ln -sf /usr/bin/true "${pkgdir}/usr/bin/steamdeps"

  install -Dm 644 subprojects/steam-devices/60-steam-input.rules \
    "${pkgdir}/usr/lib/udev/rules.d/60-steam-input.rules"
  install -Dm 644 subprojects/steam-devices/60-steam-vr.rules \
    "${pkgdir}/usr/lib/udev/rules.d/60-steam-vr.rules"

  # Jupiter
  # Install permissive input rules.  These largely supercede the narrow rules in the launcher, but not completely
  # (e.g. some tty rules)
  install -Dm 644 "${srcdir}/70-steam-jupiter-input.rules" \
    "${pkgdir}/usr/lib/udev/rules.d/70-steam-jupiter-input.rules"
  install -Dm 644 "${srcdir}/70-steam-jupiter-leds.rules" \
    "${pkgdir}/usr/lib/udev/rules.d/70-steam-jupiter-leds.rules"

  # Additional wakeup rules for fremont. These should be upstreamed
  install -Dm 644 "${srcdir}/99-power-wakeup.rules" \
    "${pkgdir}/usr/lib/udev/rules.d/99-power-wakeup.rules"

  # Jupiter
  # Replace the runtime with our own wrapper
  rm "${pkgdir}/usr/bin/steam-runtime"
  install -Dm 755 "${srcdir}/steam-jupiter.sh" "${pkgdir}/usr/bin/steam-jupiter"
  ln -sf /usr/bin/steam-jupiter "${pkgdir}/usr/bin/steam"

  # Replace bootstrapper with fat one
  rm "$pkgdir"/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
  install -Dm 644 "$srcdir/$_fat_bootstrap" "$pkgdir"/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
}

# vim: ts=2 sw=2 et:

# Maintainer: Vladislav Nepogodin (vnepogodin) <nepogodin.vlad@gmail.com>

pkgname=cachyos-zsh-config
pkgver=1.0.0
pkgrel=2
pkgdesc="Zsh configuration for CachyOS"
arch=(any)
url="https://github.com/CachyOS/$pkgname"
license=('GPL')
depends=('zsh' 'fzf' 'vim'
         'zsh-autosuggestions'
         'zsh-completions'
         'zsh-history-substring-search'
         'zsh-syntax-highlighting'
         'zsh-theme-powerlevel10k'
         'powerline-fonts'
         'oh-my-zsh-git'
         'pkgfile')
makedepends=('git')
source=("git+$url.git")
md5sums=('SKIP')

pkgver() {
    cd "$srcdir/$pkgname"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd $srcdir/$pkgname
    install -D -m644 zshrc $pkgdir/etc/skel/.zshrc
}

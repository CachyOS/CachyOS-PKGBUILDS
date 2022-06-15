#!/usr/bin/env bash
asp update
asp export $(pacman -Sg plasma)
#asp export $(pacman -Sg kde-network)
#asp export $(pacman -Sg kde-accessibility)
#asp export $(pacman -Sg kde-system)
#asp export $(pacman -Sg kde-graphics)
#asp export $(pacman -Sg kde-utilities)
#asp export $(pacman -Sg kde-applications)
#asp export $(pacman -Sg qt5)
#asp export $(pacman -Sg qt6)
#asp export $(pacman -Sg xorg)
#asp export $(pacman -Sg gnome)
#asp export $(pacman -Sg gnome-extras)
#asp export $(pacman -Sg xfce)

find . -name "PKGBUILD" | xargs -I {} sed -i 's/arch=(x86_64)/arch=(x86_64_v3)/' {}
find . -name "PKGBUILD" | xargs -I {} sed -i "s/arch=('x86_64')/arch=('x86_64_v3')/" {}

files=$(find . -name "PKGBUILD")
for f in $files
do
PKGREL=$(grep -o 'pkgrel=[0-9]*' $f | grep -o '[0-9]*')
NEW_PKGREL=$(echo "$PKGREL + 0.1" | bc)
sed -i "s/pkgrel=[0-9]*/pkgrel=$NEW_PKGREL/" $f
done

files=$(find . -name "PKGBUILD")
for f in $files
do
        d=$(dirname $f)
        cd $d
        time docker run --name lto-v3 -e EXPORT_PKG=1 -e SYNC_DATABASE=1 -v $PWD:/pkg pttrr/docker-makepkg-lto-v3
        docker rm lto-v3
        cd ..
done

mv */*.tar.zst* /home/ptr1337/packages/

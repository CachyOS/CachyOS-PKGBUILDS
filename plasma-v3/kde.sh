#!/usr/bin/env bash



asp export $(pacman -Sg plasma)

asp export $(pacman -Sg kde-network)

asp export $(pacman -Sg kde-accessibility)

asp export $(pacman -Sg kde-system)

asp export $(pacman -Sg kde-graphics)

asp export $(pacman -Sg kde-utilities)

asp export $(pacman -Sg kde-applications)

#asp export $(pacman -Sg kf5)

#asp export $(pacman -Sg qt5)

#asp export $(pacman -Sg qt6)

asp export $(pacman -Sg xorg)





find . -name "PKGBUILD" | xargs -I {} sed -i 's/arch=(x86_64)/arch=(x86_64_v3)/' {}



find . -name "PKGBUILD" | xargs -I {} sed -i "s/arch=('x86_64')/arch=('x86_64_v3')/" {}



#find . -name "PKGBUILD" | xargs -I {} sed -i "s/pkgname=/export CC=clang\\nexport CXX=clang++\\nexport LD=ld.lld\\nexport CC_LD=lld\\nexport CXX_LD=lld\\nexport AR=llvm-ar\\nexport NM=llvm-nm\\nexport STRIP=llvm-strip\\nexport OBJCOPY=
llvm-objcopy\\nexport OBJDUMP=llvm-objdump\\nexport READELF=llvm-readelf\\nexport RANLIB=llvm-ranlib\\nexport HOSTCC=clang\\nexport HOSTCXX=clang++\\nexport HOSTAR=llvm-ar\\nexport HOSTLD=ld.lld\\npkgname=/" {}



#find . -name "PKGBUILD" | xargs -I {} sed -i 's/cmake=/export CFLAGS="${CFLAGS} -flto=thin"\\nexport CXXFLAGS="${CXXFLAGS} -flto=thin"\\ncmake=/' {}



files=$(find . -name "PKGBUILD")



for f in $files

do



new_pkgrel=$(grep -o 'pkgrel=[0-9]*' $f | grep -o '[0-9]*' | xargs -I {} expr {} + 1)



sed -i "s/pkgrel=[0-9]*/pkgrel=$new_pkgrel/" $f



done





files=$(find . -name "PKGBUILD")



for f in $files

do

        d=$(dirname $f)

        echo "Build KDE with CLANG, LTO and mold $f"

        cd $d

        time docker run --name dockerbuild -e EXPORT_PKG=1 -v $PWD:/pkg -v /home/ptr1337/ccache:/home/notroot/ccache pttrr/docker-makepkg-kde-v3

        cd ..

done





mv */*.tar.zst* /home/ptr1337/packages/




#!/usr/bin/env bash

#sudo pacman -Syu base-devel llvm clang lld vim git \
#  ninja cmake libffi libedit ncurses libxml2 \
#  ocaml ocaml-ctypes ocaml-findlib python-setuptools \
#  python-psutil python-sphinx python-recommonmark
  
 ## only needed if not already built 
# git clone https://github.com/h0tc0d3/llvm-git.git && cd llvm-# # git && makepkg -cfi --noconfirm

asp export alsa-lib dolphin gwenview syntax-highlighting plasma-framework kwindowsystem kwayland frameworkintegration latte-dock kinit knotifyconfig xorg-xrdb xorg-xsetroot xorg-xmessage kwin plasma-integration  libkscreen kwayland-integration xorg-xwayland kmenuedit systemsettings qt5-tools krunner kscreenlocker kactivities kdeclarative kwayland-server kirigami2 qt5-wayland wayland-protocols kate wayland plasma-desktop plasma-workspace plasma-wayland-protocol konsole ark mesa lib32-mesa zstd lib32-zstd libx11 openssl pulseaudio xorg-server  egl-wayland dbus  alsa-plugins  libxcomposite mpv ffmpeg libglvnd

find . -name "PKGBUILD" | xargs -I {} sed -i 's/arch=(x86_64)/arch=(x86_64_v3)/' {}

find . -name "PKGBUILD" | xargs -I {} sed -i "s/arch=('x86_64')/arch=('x86_64_v3')/" {}

find . -name "PKGBUILD" | xargs -I {} sed -i "s/pkgname=/export CC=clang\\nexport CXX=clang++\\nexport LD=ld.lld\\nexport CC_LD=lld\\nexport CXX_LD=lld\\nexport AR=llvm-ar\\nexport NM=llvm-nm\\nexport STRIP=llvm-strip\\nexport OBJCOPY=llvm-objcopy\\nexport OBJDUMP=llvm-objdump\\nexport READELF=llvm-readelf\\nexport RANLIB=llvm-ranlib\\nexport HOSTCC=clang\\nexport HOSTCXX=clang++\\nexport HOSTAR=llvm-ar\\nexport HOSTLD=ld.lld\\npkgname=/" {}

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
	echo "makepkg -sr --sign --skipinteg --noconfirm $f"
	cd $d
	makepkg -sr --sign --skipinteg --noconfirm $d/PKGBUILD
	cd ..
done

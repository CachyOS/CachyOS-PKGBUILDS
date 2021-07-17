#!/usr/bin/env bash

asp export oxygen-icons sonnet solid dolphin kcron khelpcenter spectacle ksystemlog  gwenview syntax-highlighting partitionmanager plasma-framework kwindowsystem kwayland frameworkintegration extra-cmake-modules latte-dock kdoctools gpsd baloo networkmanager-qt plasma-wayland-protocols kunitconversion kinit knotifyconfig ksystemstats ktexteditor libqalculate kde-cli-tools appstream-qt xorg-xrdb xorg-xsetroot kactivitymanagerd kholidays xorg-xmessage milou prison kwin plasma-integration kpeople kactivities-stats libkscreen kquickcharts kuserfeedback kio-extras kio-fuse baloo kwayland-integration xorg-xwayland gawk kdelibs4support polkit-kde-agent libxkbfile kmenuedit systemsettings baloo accountsservice xdg-user-dirs packagekit-qt5 kcmutils qt5-tools krunner kscreenlocker kactivities kdeclarative kwayland-server kirigami2 qt5-wayland kate plasma-desktop plasma-workspace konsole ark mesa lib32-mesa zstd lib32-zstd ffmpeg firefox

paru -G discord-canary lightcord-bin vscodium qownnotes  kotatogram-desktop 

find . -name "PKGBUILD" | xargs -I {} sed -i 's/arch=(x86_64)/arch=(x86_64_v3)/' {}

find . -name "PKGBUILD" | xargs -I {} sed -i "s/arch=('x86_64')/arch=('x86_64_v3')/" {}


files=$(find . -name "PKGBUILD")

for f in $files
do
	d=$(dirname $f)
	echo "makepkg -sr --sign --skipinteg --rmdeps $f"
	cd $d
	makepkg -sr --sign --skipinteg --rmdeps $d/PKGBUILD
	cd ..
done

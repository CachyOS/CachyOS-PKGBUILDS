#!/usr/bin/env bash

asp export bluedevil breeze breeze-gtk discover drkonqi kactivitymanagerd kde-cli-tools kde-gtk-config kdecoration kscreen kwayland-integration kwayland-server kwin libkscreen plasma-desktop plasma-firewall plasma-pa plama-integration plasma-workspace

find . -name "PKGBUILD" | xargs -I {} sed -i 's/arch=(x86_64)/arch=(x86_64_v3)/' {}

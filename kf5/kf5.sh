#!/usr/bin/env bash

asp export oxygen-icons sonnet solid syntax-highlighting plasma-framework kwindowsystem kwayland frameworkintegration extra-cmake-modules latte-dock

find . -name "PKGBUILD" | xargs -I {} sed -i 's/arch=(x86_64)/arch=(x86_64_v3)/' {}

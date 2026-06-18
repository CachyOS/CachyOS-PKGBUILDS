#!/usr/bin/env bash
# Download and install the SteamOS bootstrap to speed up first boot setup.
# Runs as a first-boot oneshot service because pacman no longer permits
# network access from package scriptlets (.install).
set -euo pipefail

URL="https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steam-jupiter-stable-1.0.0.85-2-x86_64.pkg.tar.zst"
BOOTSTRAP_SHA512=a013473d28a9d10a865b543ee1c42fa514c4af383b63f7dbf8e38d18e358ebdbc247caff1e39cc372a71b05fdd506f2356e1af0c5404a95f6615191d994e0fbf
DEST=/usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

echo "Downloading SteamOS bootstrap"
curl -fL -o "$workdir/steam-jupiter-stable.tar.zst" "$URL"

echo "Extracting bootstraplinux_ubuntu12_32.tar.xz"
tar -I zstd -xOf "$workdir/steam-jupiter-stable.tar.zst" \
    usr/lib/steam/bootstraplinux_ubuntu12_32.tar.xz > "$workdir/bootstraplinux_ubuntu12_32.tar.xz"

echo "$BOOTSTRAP_SHA512  $workdir/bootstraplinux_ubuntu12_32.tar.xz" | sha512sum -c - >/dev/null 2>&1 || {
    echo "Extraction/verification failed!" >&2
    exit 1
}

install -d "$(dirname "$DEST")"
mv -f "$workdir/bootstraplinux_ubuntu12_32.tar.xz" "$DEST"
echo "SteamOS bootstrap installed to $DEST"

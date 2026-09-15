#!/bin/bash

set -euo pipefail

STEAM_LINKS="$HOME"/.steam
STEAM_DIR="$HOME"/.local/share/Steam

REGISTRY="$STEAM_LINKS"/registry.vdf
REGISTRY_BAK="$HOME"/.local/share/steam_registry_oobe.vdf

(
  if [[ -f "$STEAM_DIR"/Steam.cfg ]] && grep -q "^# OOBE Inhibit" "$STEAM_DIR"/Steam.cfg; then
    # If steam is setup in an OOBE fashion, we want to blow it away and re-bootstrap
    # See steam-jupiter-oobe's variant of this entrypoint.

    # Move the registry to a oobe backup copy
    [[ ! -e "$REGISTRY" ]] || cp -v "$REGISTRY" "$REGISTRY_BAK"

    # Blow away
    rm -rf --one-file-system "$STEAM_DIR" "$STEAM_LINKS"
  fi

  # If we're bootstrapping a fresh instance of Steam, use the oobe registry.vdf if we have it
  if [[ -e "$REGISTRY_BAK" && ! -e "$REGISTRY" ]]; then
    mkdir -pv "$STEAM_LINKS"
    cp -v "$REGISTRY_BAK" "$REGISTRY"
  fi

  # For beta lifecycle, we need to be on a steampal branch.
  if cd ~/.steam/root/package || cd ~/.local/share/Steam/package; then
    if [[ ! -e beta || $(cat beta) = *neptune || $(cat beta) = publicbeta || $(cat beta) = "steampal_stable_d89c8fc0c37b9f06864d20456852ed2eb7e350b3" ]]; then
      echo -n "steamdeck_stable" > beta
    fi
  fi
)
exec /usr/lib/steam/steam -steamdeck "$@"

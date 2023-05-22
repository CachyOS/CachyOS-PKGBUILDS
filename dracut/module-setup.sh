#!/bin/bash

# called by dracut
check() {
    dracut_module_included btrfs || return 1
    return 0
}

# called by dracut
depends() {
    return 0
}

# called by dracut
install() {
    inst mktemp
    hostonly='' instmods overlay
    inst_hook pre-pivot 000 "$moddir/snapshot-overlay.sh"
}

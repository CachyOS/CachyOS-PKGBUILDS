#!/bin/bash
function mount_snapshot_overlay() {
    local root_mnt="$NEWROOT"
    if [[ "$(findmnt --mountpoint "$root_mnt" -o FSTYPE -n)" = "btrfs" ]] && [[ "$(btrfs property get ${root_mnt} ro)" != "ro=false" ]]; then
        local ram_dir=$(mktemp -d -p /)
        mount -t tmpfs cowspace ${ram_dir}
        mkdir -p ${ram_dir}/{upper,work}
        mount -t overlay -o lowerdir=${root_mnt},upperdir=${ram_dir}/upper,workdir=${ram_dir}/work rootfs ${root_mnt}
    fi
}

mount_snapshot_overlay

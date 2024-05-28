#!/bin/bash
function mount_snapshot_overlay() {
    local root_mnt="$NEWROOT"
    local UUID FSTYPE
    IFS=" " read -r UUID FSTYPE < <(findmnt --mountpoint "$root_mnt" -o UUID,FSTYPE -n)
    if [[ "$FSTYPE" = "btrfs" ]] && [[ "$(btrfs property get "${root_mnt}" ro)" == "ro=true" ]]; then
        local ram_dir=$(mktemp -d -p /)

        # we are required to mount the top btrfs volume and then remount it as read-write explicitly to avoid all subvolumes being RO
        mount -t btrfs "UUID=${UUID}" "${ram_dir}"
        mount -o remount,rw "${ram_dir}"
        umount "${ram_dir}"

        mount -t tmpfs cowspace ${ram_dir}
        mkdir -p ${ram_dir}/{upper,work}
        mount -t overlay -o lowerdir=${root_mnt},upperdir=${ram_dir}/upper,workdir=${ram_dir}/work rootfs ${root_mnt}
    fi
}

mount_snapshot_overlay

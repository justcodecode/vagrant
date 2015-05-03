#!/bin/bash
get_swap_size() {
    local size=`parted /dev/xvdb print|grep Disk|grep -o '[0-9]*'`
    if [ ${size} -le 16384 ]
    then
        SWAP_SIZE=256
    else
        SWAP_SIZE=2048
    fi
}

mount_swap() {
    echo "`date` mount swap"
    if [ ! -e /dev/xvdb ]; then return; fi
    get_swap_size
    if [ ! -e /dev/xvdb1 ]; then
        sfdisk /dev/xvdb << EOF
,${SWAP_SIZE},S
,,L
EOF
        echo "`date` wait 5 seconds for partition to be available"
        sleep 5
    fi
    echo "`date` make and mount swap"
    mkswap /dev/xvdb1 && swapon /dev/xvdb1
}

AVAIL_DISKS=()

check_avail_ephemeral_disks() {
    for DISK in '/dev/xvdb2' '/dev/xvdc' '/dev/xvdd' '/dev/xvde'; do
        if [ -e ${DISK} ]; then AVAIL_DISKS+=(${DISK}); fi
    done
}

mount_single_ephemeral_disk() {
    mkfs.ext4 /dev/xvdb2
    mount /dev/xvdb2 /mnt/ephemeral
}

mount_raid0_ephemeral_disks() {
    if [ ! -e /dev/md127 ]; then
        yes | mdadm --create /dev/md127 --level=0 --raid-devices=${#AVAIL_DISKS[@]} ${AVAIL_DISKS[@]}
        mkfs.ext4 /dev/md127
    fi
    mount /dev/md127 /mnt/ephemeral
}

mount_ephemeral() {
    echo "`date` mount ephemeral"
    check_avail_ephemeral_disks
    if [ ${#AVAIL_DISKS[@]} -eq 0 ]; then return; fi
    mkdir -p /mnt/ephemeral
    mountpoint -q /mnt/ephemeral
    if [ $? -ne 0 ]; then
        if [ ${#AVAIL_DISKS[@]} -eq 1 ]
        then
            mount_single_ephemeral_disk
        else
            mount_raid0_ephemeral_disks
        fi
    fi
    chmod 777 /mnt/ephemeral
}

umount /mnt # umount /dev/xvdb if ubuntu mounted already
mount_swap
mount_ephemeral
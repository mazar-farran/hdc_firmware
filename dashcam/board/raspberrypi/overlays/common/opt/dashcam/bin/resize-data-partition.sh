#!/bin/sh

# Ensure no data is waiting to be written
sync

# Resize data partition and filesystem to fill emmc
umount /dev/mmcblk0p4
parted /dev/mmcblk0 resizepart 4 100%
resize2fs /dev/mmcblk0p4
fsck.ext4 -p /dev/mmcblk0p4
mount /dev/mmcblk0p4

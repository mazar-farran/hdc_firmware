#!/bin/sh
#
# Shrink the partition to retrigger the expansion of it.
#

sh /opt/dashcam/bin/stop_all.sh
sh /opt/dashcam/bin/storage/clean_data.sh
umount /dev/mmcblk0p4
parted /dev/mmcblk0 resizepart 4 772MB
resize2fs /dev/mmcblk0p4
mount /dev/mmcblk0p4


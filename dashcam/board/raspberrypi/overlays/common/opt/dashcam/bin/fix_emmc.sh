
echo "Stopping services"
/opt/dashcam/bin/stop_all.sh
umount /dev/mmcblk0p4
yes | mkfs.ext4 /dev/mmcblk0p4
e2label /dev/mmcblk0p4 data
mount -a
echo "Writing result file"
touch /mnt/data/emmc_fixed
echo "Rebooting"
reboot

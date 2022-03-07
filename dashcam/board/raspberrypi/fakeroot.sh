#!/bin/bash

# Start a console session on the virtual terminal so we can login with
# keyboard.  Force the link in case it is already there which you can get
# in weird partial build cases.
mkdir -p ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/systemd/system/getty.target.wants/
ln -sf /usr/lib/systemd/system/getty@.service ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/systemd/system/getty.target.wants/getty@tty1.service
  
# Make sure the boot built-in-test runs on start.
ln -sf /etc/systemd/system/bootbit.service ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/systemd/system/multi-user.target.wants/bootbit.service

# Remove the tmpfs on /var.  We're already overlaying an entire tmpfs over the RO
# root so this is redundant.  But more than that, having an entry for /var screws
# things up when:
# - we're using usbmount
# - you boot with a USB storage drive already connected
# Yeah, wtf?  usbmount creates a /var/run/usbmount directory when it detects
# a USB drive.  I think this may be happening before we run the init script to do
# the overlay filesystem and is screwing up /var so that other processes like RAUC can't
# write their data, which causes the RAUC daemon to not start.  Sigh, it's just
# one workaround after another...
sed -i '/tmpfs \/var tmpfs/d' ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/fstab

# Mount the data partition.  
echo "LABEL=data /mnt/data ext4 defaults,data=journal,noatime 0 0" >> ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/fstab

# Don't let non-root users see the hostapd.conf file since it has password info.
chmod og-rw ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/hostapd.conf

#!/bin/bash

# Start a console session on the virtual terminal so we can login with
# keyboard.  Force the link in case it is already there which you can get
# in weird partial build cases.
mkdir -p ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/systemd/system/getty.target.wants/
ln -sf /usr/lib/systemd/system/getty@.service ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/systemd/system/getty.target.wants/getty@tty1.service
  
# Make sure the boot built-in-test runs on start.
ln -sf /etc/systemd/system/bootbit.service ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/systemd/system/multi-user.target.wants/bootbit.service

# Mount the data partition.  
echo "LABEL=data /mnt/data ext4 defaults,data=journal,noatime 0 0" >> ${BUILD_DIR}/buildroot-fs/squashfs/target/etc/fstab

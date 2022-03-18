#!/bin/sh

set -eu

# The only way in Buildroot we can figure out what configuration we are working with is by
# having the path of this script route through the symlinked board/config directories, and
# then pulling the directory name out of the path.  So BOARD_NAME in that case
# may be "raspberrypicm4io_prod_64" for example.
BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"

IS_DEV=0
BUILD_TYPE="prod"
if [[ ${BOARD_NAME} = *_dev ]]
then
	IS_DEV=1
  BUILD_TYPE="dev"
fi

# Copy the custom command line file.  This command line is what is used by the 
# RPi firmware at the beginning of boot, up until the U-Boot script takes over.
install -D -m 0644 ${BR2_EXTERNAL_DASHCAM_PATH}/board/raspberrypi/cmdline.txt ${BINARIES_DIR}/rpi-firmware/cmdline.txt

# Copy the public certificates to the target dir.
install -D -m 0644 ${BR2_EXTERNAL_DASHCAM_PATH}/board/raspberrypi/pki/dev/keyring/cert.pem ${TARGET_DIR}/etc/rauc/keyring/

# Populate version info.
rm -f ${TARGET_DIR}/etc/version.json
cat >> ${TARGET_DIR}/etc/version.json << EOF
{
  "branch": "$(git -C ${BR2_EXTERNAL_DASHCAM_PATH} branch --show-current)",
  "build_date": "$(date)",
  "hash": "$(git -C ${BR2_EXTERNAL_DASHCAM_PATH} rev-parse --short HEAD)",
  "build_type": "${BUILD_TYPE}"
}
EOF

# Options necessary for usbmount.
sed -i "s/PrivateMounts=yes/PrivateMounts=no/g" ${TARGET_DIR}/lib/systemd/system/systemd-udevd.service
sed -i "s/FS_MOUNTOPTIONS=\"\"/FS_MOUNTOPTIONS=\"-fstype=vfat,gid=users,dmask=0007,fmask=0117\"/g" ${TARGET_DIR}/etc/usbmount/usbmount.conf
sed -i "s/sync,noexec,nodev/noexec,nodev/g" ${TARGET_DIR}/etc/usbmount/usbmount.conf

# Deconflict port 53 which dnsmasq is trying to use.  This tells systemd-resolved to not get in the way.
sed -i "s/#DNSStubListener=yes/DNSStubListener=no/g" ${TARGET_DIR}/etc/systemd/resolved.conf

if [[ ${IS_DEV} -ne 0 ]]; then
  # If we haven't generated SSH keys for the target yet do so now.  If they're
  # already there this won't overwrite them.
  ssh-keygen -A -f ${TARGET_DIR}

  # Make sure any SSH private keys do not have read (or any) permissions.
  chmod go-rwx \
    ${TARGET_DIR}/etc/ssh/ssh_host_dsa_key \
    ${TARGET_DIR}/etc/ssh/ssh_host_ecdsa_key \
    ${TARGET_DIR}/etc/ssh/ssh_host_ed25519_key \
    ${TARGET_DIR}/etc/ssh/ssh_host_rsa_key
fi

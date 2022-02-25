#!/bin/bash

set -eu

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"

# The buildroot method for creating a U-Boot script from a source seems to
# produce a binary SCR file and doesn't run.  So easy enough for us to do it.
mkimage -A arm -O linux -T script -C none \
  -n "${BR2_EXTERNAL_DASHCAM_PATH}/board/raspberrypi/uboot_${BOARD_NAME}.scr" \
  -d "${BR2_EXTERNAL_DASHCAM_PATH}/board/raspberrypi/uboot_${BOARD_NAME}.scr" \
  "${BINARIES_DIR}/boot.scr.uimg"

GENIMAGE_CFG="${BOARD_DIR}/genimage_${BOARD_NAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

# Generate a RAUC update bundle for the root filesystem.
[ -e ${BINARIES_DIR}/update.raucb ] && rm -rf ${BINARIES_DIR}/update.raucb
[ -e ${BINARIES_DIR}/rauc ] && rm -rf ${BINARIES_DIR}/rauc
mkdir -p ${BINARIES_DIR}/rauc

cat >> ${BINARIES_DIR}/rauc/manifest.raucm << EOF
[update]
compatible=dashcam-rpi
version=tbd

[bundle]
format=verity

[image.boot]
filename=boot.vfat

[image.rootfs]
filename=rootfs.ext4
EOF

# These have to be hardlinks -- symlinks will fail when RAUC goes to generate
# the signature.
ln -L ${BINARIES_DIR}/boot.vfat ${BINARIES_DIR}/rauc/boot.vfat
ln -L ${BINARIES_DIR}/rootfs.ext4 ${BINARIES_DIR}/rauc/rootfs.ext4

${HOST_DIR}/bin/rauc bundle \
	--cert ${BOARD_DIR}/pki/dev/keyring/cert.pem \
	--key ${BOARD_DIR}/pki/dev/private/key.pem \
	${BINARIES_DIR}/rauc/ \
	${BINARIES_DIR}/update.raucb
		
exit $?

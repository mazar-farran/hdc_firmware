#!/bin/sh
#
# Set the hostname on start based on the serial number.

set -euo pipefail

# Field 28 of the One Time Programmable memory is serial number.
# https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#otp-register-and-bit-definitions
SN=$(vcgencmd otp_dump | grep 28: | awk -F":" '{print $2}')
HOSTNAME="dashcam-${SN}"

# Set in 3 places.  You would think /etc/hostname would drive what is used
# by the "hostname" command but no, they are decoupled.
echo "${HOSTNAME}" > /etc/hostname
sed -i "s/dashcam/${HOSTNAME}/g" /etc/hosts
hostname ${HOSTNAME}

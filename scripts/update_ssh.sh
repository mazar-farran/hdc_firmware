#!/bin/bash
#
# Writes a RAUC update bundle to the target, installs it, and reboots.  All 
# over SSH to the root account, so this is purely for development.

set -euo pipefail

SCRIPT_PATH=`realpath $0`
SCRIPT_DIR=`dirname $0`
SCRIPT_NAME=`basename ${SCRIPT_PATH}`

DEFAULT_FILE_PATH=`realpath ${SCRIPT_DIR}/../output/images/update.raucb`
FILE_PATH=${DEFAULT_FILE_PATH}

usage()
{
  echo "${SCRIPT_NAME} target_ip [OPTIONS]"
  echo ""
  echo "Required:"
  echo "  target_ip     IP address of the target."
  echo ""
  echo "Optional:"
  echo "  -h, --help    Shows usage."
  echo "  -f, --file    Update file to install. Defaults to ${DEFAULT_FILE_PATH}."
  exit 1
}

PARSED=`getopt --options=hf: --longoptions=help,file: --name "${SCRIPT_NAME}" -- "$@"`
eval set -- "$PARSED"

while true; do
  case "$1" in
    -h|--help)
      # Usage exits.
      usage
      ;;
    -f|--file)
      FILE_PATH="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Programming error"
      exit 2
      ;;
  esac
done

if [[ $# -ne 1 ]]; then
  usage
fi

TARGET_IP="$1"
FILENAME=`basename ${FILE_PATH}`

scp ${FILE_PATH} root@${TARGET_IP}:/tmp
ssh -t root@${TARGET_IP} "rauc install /tmp/${FILENAME} && reboot"

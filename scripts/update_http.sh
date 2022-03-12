#!/bin/bash
#
# Writes a RAUC update bundle to the target, installs it, and reboots,
# using the production HTTP interface.

ERROR_USAGE=1
ERROR_OPTIONS=2
ERROR_NO_CURL=3
ERROR_NO_JQ=4
ERROR_BAD_STATE=5
ERROR_BAD_POST=6
ERROR_NO_UPDATE_FILE=7
ERROR_UPDATE_FAILED=8
ERROR_UPDATE_TIMEOUT=9
ERROR_REBOOT_TIMEOUT=10

TIMEOUT_UPDATE_S=20
TIMEOUT_REBOOT_S=50
REBOOT_SLEEP_TIME_S=30

# Test for curl dependency.
curl --version > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Error: curl not installed."
    exit ${ERROR_NO_CURL}
fi

jq --version > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "Error: jq not installed."
    exit ${ERROR_NO_JQ}
fi

# Don't use 'e' here since we have a bunch of bash arithmetic that sums to 0.
# -e thinks of that as a failure.
set -uo pipefail

SCRIPT_PATH=`realpath $0`
SCRIPT_DIR=`dirname $0`
SCRIPT_NAME=`basename ${SCRIPT_PATH}`

DEFAULT_FILE_PATH="$(realpath ${SCRIPT_DIR}/..)/output/images/update.raucb"
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
  exit ${ERROR_USAGE}
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
      exit ${ERROR_OPTIONS}
      ;;
  esac
done

if [[ $# -ne 1 ]]; then
  echo "Error: no target_ip given."
  usage
fi

TARGET_IP="$1"

if [[ ! -f ${FILE_PATH} ]]; then
  echo "Error: upload file does not exist."
  exit ${ERROR_NO_UPDATE_FILE}
fi

# Test for connectivity.
CODE=$(curl -s -o /dev/null -w "%{http_code}" -X GET http://${TARGET_IP}:8080/status)
if [[ ${CODE} -ne 200 ]]; then
  echo "Error: unable to get status from server."
fi

function get_state()
{
  local JSON=$(curl -s -X GET http://${TARGET_IP}:8080/status)
  local STATE=$(echo ${JSON} | jq .state)
  echo ${STATE}
}

function get_rauc_state()
{
  local JSON=$(curl -s -X GET http://${TARGET_IP}:8080/status)
  local STATE=$(echo ${JSON} | jq .rauc_state)
  echo ${STATE}
}

function get_last_error()
{
  local JSON=$(curl -s -X GET http://${TARGET_IP}:8080/status)
  local LAST_ERROR=$(echo ${JSON} | jq .last_error)
  echo ${LAST_ERROR}
}

function get_time_s()
{
  echo $(date +%s)
}

STATE=$(get_state) 
echo "Server state: ${STATE}"
if [[ ${STATE} != \"ready\" && ${STATE} != \"failed\" ]]; then
  echo "Error: server must be in ready or failed state."
  exit ${ERROR_BAD_STATE}
fi

UPDATE_START_TIME_S=$(get_time_s)
echo -e "\nPosting update..."
CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST --data-binary @${FILE_PATH} http://${TARGET_IP}:8080/update)
if [[ ${CODE} -ne 200 ]]; then
  echo "Error: got error status code (${CODE}) from server."
  exit ${ERROR_BAD_POST}
fi

while true
do
  STATE=$(get_state)

  if [[ ${STATE} == \"rauc_update\" ]]; then
    RAUC_STATE=$(get_rauc_state)    
    echo "Server state: ${STATE}; RAUC state: ${RAUC_STATE}"
  else
    echo "Server state: ${STATE}"
  fi

  if [[ ${STATE} == \"reboot\" ]]; then
    echo -e "\nUpdate successful, this program will wait for the target to reboot."
    echo -e "This could take a bit, ctrl+c to exit now.\n"
    break
  fi

  if [[ ${STATE} == \"failed\" ]]; then
    LAST_ERROR=$(get_last_error)
    echo -e "\nUpdate failed: ${LAST_ERROR}"
    exit ${ERROR_UPDATE_FAILED}
  fi

  let "TIME_SINCE_START_S = $(get_time_s) - ${UPDATE_START_TIME_S}"
  if [[ ${TIME_SINCE_START_S} -ge ${TIMEOUT_UPDATE_S} ]]; then
    echo "Error: update timed out."
    exit ${ERROR_UPDATE_TIMEOUT}
  fi

  sleep 1
done

REBOOT_START_TIME_S=$(get_time_s)
while true
do
  let "TIME_SINCE_START_S = $(get_time_s) - ${REBOOT_START_TIME_S}"
  let "TIME_REMAINING_S = ${REBOOT_SLEEP_TIME_S} - ${TIME_SINCE_START_S}"

  if [[ ${TIME_REMAINING_S} -le 0 ]]; then
    break
  fi

  echo -e -n "\r\033[KSleeping for ${TIME_REMAINING_S} seconds..."
  sleep 1
done

echo -e "\n"

while true
do
  STATE=$(get_state)
  echo "Server state: ${STATE}"

  if [[ ${STATE} == \"ready\" ]]; then
    echo -e "Target back online."
    break
  fi

  let "TIME_SINCE_START_S = $(get_time_s) - ${REBOOT_START_TIME_S}"
  if [[ ${TIME_SINCE_START_S} -ge ${TIMEOUT_REBOOT_S} ]]; then
    echo "Error: reboot timed out."
    exit ${ERROR_REBOOT_TIMEOUT}
  fi

  sleep 1
done

echo -e "Querying version information:"
curl -s i -X GET http://${TARGET_IP}:8080/version
echo ""
echo -e "\nUpdate complete!"

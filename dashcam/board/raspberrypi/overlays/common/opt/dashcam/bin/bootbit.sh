#!/bin/sh
#
# Built-in-test that runs on boot to verify a boot is good and to handle
# success and failure.
#
# A note on time: I'm distrustful of using the system clock since this is a target
# that does not have accurate time and may have a clock jump if NTP sync kicks in.
# So I'm going to use loops with a number of iterations and 1 second sleeps, so 
# the number of iterations approximates amount of time the loop may run.
# 
# Right now a failure exits with a non-zero code.  We can leave it up to the systemd
# configuration to decide how to handle that.
#
# Print echoes get written to systemd/journald.  View using either:
# journalctl [OPTIONS]
# systemctl status bootbit
# Additionally, errors get routed to the kernel log (i.e. dmesg).

print_info() {
  echo -e "$1" | systemd-cat -p info -t bootbit
}

print_error() {
  echo -e "$1" > /dev/kmsg
  echo -e "$1" | systemd-cat -p emerg -t bootbit
}

fail() {
  print_error "BIT failed: $1"
  exit 1
}

# Gets a process ID given a greppable string.
get_proc_id() {
  local PID
  # The Busybox version of ps is pretty limited and we don't have pgrep.  The args
  # column is the richest and gives the full path of the process.  But that isn't
  # great because we'll also have the "grep" command show up in the result.  So
  # used the "comm" column but beware since that truncates the process name if
  # it is too long.
  PID=$(ps -o pid,comm | grep "$1" | awk '{print $1}')
  echo "${PID}"
}

# Checks process IDs for equivalence and reboots if they don't match.
check_proc_ids() {
  [ "$1" != "$2" ] && fail "$3 PIDs do not match; $1, $2"
}

# Note we're going to search for these using the "comm" column of ps which
# truncates the process name to 15 chars.
OU_PROC="onboardupdater"
RAUC_PROC="rauc"
CCF_PROC="capable_camera_"
BRIDGE_PROC="libcamera-bri"

OU_PID=
RAUC_PID=
CCF_PID=
BRIDGE_PID=

# This first loop tries to identify the PIDs of processes we are interested in.
ITER=0
NUM_ITERS=20
while true; do
  [ -z "${OU_PID}" ] && OU_PID=$(get_proc_id "${OU_PROC}")
  [ -z "${RAUC_PID}" ] && RAUC_PID=$(get_proc_id "${RAUC_PROC}")
  [ -z "${CCF_PID}" ] && CCF_PID=$(get_proc_id "${CCF_PROC}")
  [ -z "${BRIDGE_PID}" ] && BRIDGE_PID=$(get_proc_id "${BRIDGE_PROC}")
  
  # The libcamera-bridge process is not at the point where we can run it
  # without erroring.  So don't make it part of our checks... yet.
  # TODO(chris.shaw): fix libcamera-bridge startup.
  if [ -n "${OU_PID}" ] &&
    [ -n "${RAUC_PID}" ] &&
    [ -n "${CCF_PID}" ] #&&
    # [ -n "${BRIDGE_PID}" ]
  then
    # If we've found all the processes we're looking for we can kick out early.
    break
  fi

  ITER=$((ITER + 1))

  [ ${ITER} -ge ${NUM_ITERS} ] && fail "unable to find all processes"

  sleep 1
done

# Now we allow some settling time so that when we wake up we can check the PIDs
# again to make sure the processes haven't crashed and restarted.
sleep 5

NEW_OU_PID=$(get_proc_id "${OU_PROC}")
NEW_RAUC_PID=$(get_proc_id "${RAUC_PROC}")
NEW_CCF_PID=$(get_proc_id "${CCF_PROC}")
NEW_BRIDGE_PID=$(get_proc_id "${BRIDGE_PROC}")

check_proc_ids "${OU_PID}" "${NEW_OU_PID}" "${OU_PROC}"
check_proc_ids "${RAUC_PID}" "${NEW_RAUC_PID}" "${RAUC_PROC}"
check_proc_ids "${CCF_PID}" "${NEW_CCF_PID}" "${CCF_PROC}"

# The libcamera-bridge process is not at the point where we can run it
# without erroring.  So don't make it part of our checks... yet.
# TODO(chris.shaw): fix libcamera-bridge startup.
#check_proc_ids "${BRIDGE_PID}" "${NEW_BRIDGE_PID}" "${BRIDGE_PROC}"

# We should probably pull the expected address from dhcpcd.conf.
WIFI_IP=192.168.0.10
# The wlan0 interface is the last thing to come up.  So we'll give it a bit more time.
ITER=0
NUM_ITERS=10
while true; do
  # TODO(chris.shaw): there may be a better way of testing this.  
  ip addr show wlan0 | grep ${WIFI_IP} > /dev/null 2>&1
  [ "$?" -eq 0 ] && break

  ITER=$((ITER + 1))

  [ ${ITER} -ge ${NUM_ITERS} ] && fail "wlan0 is not up with expected IP address"

  sleep 1
done

# Test the onboard updater is answering requests on the wifi interface.
wget http://192.168.0.10:8080/status --spider > /dev/null 2>&1
[ "$?" -ne 0 ] && fail "cannot get status from onboard updater"

# Test that the persistent data partition is mounted.
cat /proc/mounts | grep /mnt/data > /dev/null 2>&1
[ "$?" -ne 0 ] && fail "data partition not mounted"

# This is the positive exit condition.
rauc status mark-good

#!/bin/sh
#
# Built-in-test that runs on boot to verify a boot is good and to handle
# success and failure.
#
# A note on time: I'm distrustful of using the system clock since this is a target
# that does not have accurate time and may have a clock jump if NTP sync kicks in.
# So I'm going to use loops with a number of iterations and 1 second sleeps, so 
# the number of iterations approximates amount of time the loop may run.

# Prints to the dmesg log for debugging purposes.
print_debug() {
  echo -e "(bootbit) | $1" >/dev/kmsg
}

# Gets a process ID given a greppable string.
get_proc_id() {
  local PID
  PID=$(ps -o pid,comm | grep "$1" | awk '{print $1}')
  echo "${PID}"
}

# Checks process IDs for equivalence and reboots if they don't match.
check_proc_ids() {
  if [ "$1" != "$2" ]; then
    print_debug "BIT failed: $3 PIDs do not match"
    # TODO(chris.shaw): make this a reboot.
    exit 1
  fi
}

OU_PROC="onboardupdater"
RAUC_PROC="rauc"

OU_PID=
RAUC_PID=

# This first loop tries to identify the PIDs of processes we are interested in.
ITER=0
NUM_ITERS=20
while true; do
  if [ -z "${OU_PID}" ]; then
    OU_PID=$(get_proc_id "${OU_PROC}")
  fi

  if [ -z "${RAUC_PID}" ]; then
    RAUC_PID=$(get_proc_id "${RAUC_PROC}")
  fi

  if [ -n "${OU_PID}" ] &&
    [ -n "${RAUC_PID}" ]; then
    # If we've found all the processes we're looking for we can kick out early.
    break
  fi

  ITER=$((ITER + 1))

  if [ ${ITER} -ge ${NUM_ITERS} ]; then
    print_debug "BIT failed: unable to find all processes."
    # TODO(chris.shaw): make this a reboot.
    exit 1
  fi

  sleep 1
done

# Now we allow some settling time so that when we wake up we can check the PIDs
# again to make sure the processes haven't crashed and restarted.
sleep 5

NEW_OU_PID=$(get_proc_id "${OU_PROC}")
NEW_RAUC_PID=$(get_proc_id "${RAUC_PROC}")

check_proc_ids "${OU_PID}" "${NEW_OU_PID}" "${OU_PROC}"
check_proc_ids "${RAUC_PID}" "${NEW_RAUC_PID}" "${RAUC_PROC}"

# The wlan0 interface is the last thing to come up.  So we'll give it a bit more time.
ITER=0
NUM_ITERS=10
while true; do
  # TODO(chris.shaw): there may be a better way of testing this.  At least we could pull the expected
  # address from dhcpcd.conf.
  ip addr show wlan0 | grep 192.168.0.10 >/dev/null 2>&1
  if [ "$?" -eq 0 ]; then
    # Found it.  Kick out early.
    break
  fi

  ITER=$((ITER + 1))

  if [ ${ITER} -ge ${NUM_ITERS} ]; then
    print_debug "BIT failed: wlan0 is not up with expected IP address."
    # TODO(chris.shaw): make this a reboot.
    exit 1
  fi

  sleep 1
done

# This is the positive exit condition.
rauc status mark-good

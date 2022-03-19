#!/usr/bin/env python3
#
# Performs update endurance tests.

import json
import os
import random
import subprocess
import sys
import time
from tempfile import mkdtemp

import click
import requests

# The slot (0 or 1) that will receive the new update.
active_slot = None
# The version (0, 1, 2) that is installed to the new update.
active_version = None
# The versions (0, 1, 2) currently occupying the two available slots.
slot_versions = [None, None]
# Amount of time we allow after posting an update for the system to reboot and come up again.
reboot_timeout_s = 60
# Amount of time we allow for an HTTP response.
request_timeout_s = 0.1
# Port the onboard updater is running on.
target_port = 8080
# The update bundles as binary files read into memory.
updates = [None, None, None]
# The version file from the update bundles.
version_json = [None, None, None]


class PowerCycleConfig:
    def __init__(self, enable, percent, time_range, command):
        self.enable = enable
        self.percent = percent
        self.time_range = time_range
        self.command = command


class PowerCycleIteration:
    def __init__(self, config):
        self.config = config
        self.active = False
        self.time = 0


def set_active_slot():
    """Sets the active slot to 0 or 1."""
    global active_slot
    if active_slot is None or active_slot == 1:
        active_slot = 0
    else:
        active_slot = 1


def get_inactive_slot():
    if active_slot == 0:
        return 1
    else:
        return 0


def get_version_to_use():
    """Finds the version that is not currently in a slot."""
    if 0 not in slot_versions:
        return 0
    elif 1 not in slot_versions:
        return 1
    else:
        return 2


def get_status(base_uri):
    """Gets the status from the target. Throws a RuntimeError on a request exception."""
    try:
        r = requests.get(f"{base_uri}/status", timeout=request_timeout_s)
        if r.status_code != requests.codes.ok:
            raise RuntimeError(f"Got a code of {r.status_code} on a GET/status.")

        return r.json()
    except requests.exceptions.RequestException:
        raise RuntimeError("Unable to get response on GET/status request.")


def get_build_date(base_uri):
    """
    Gets the build date from the target via the GET/version message.
    Throws a RuntimeError on a request exception.
    """
    try:
        r = requests.get(f"{base_uri}/version", timeout=request_timeout_s)
        if r.status_code != requests.codes.ok:
            raise RuntimeError(f"Got a code of {r.status_code} on a GET/version.")

        return r.json()["build_date"]
    except requests.exceptions.RequestException:
        raise RuntimeError("Unable to get response on GET/version request.")


def post_update(base_uri, version):
    """Posts a binary update bundle to the target. Throws a RuntimeError on a request exception."""
    try:
        r = requests.post(
            f"{base_uri}/update", data=updates[version], headers={"Content-Type": "application/octet-stream"}
        )
        if r.status_code != requests.codes.ok:
            raise RuntimeError(f"Got a code of {r.status_code} on a POST/update.")
    except requests.exceptions.RequestException:
        raise RuntimeError("Unable to get response on POST/update request.")


def wait_for_terminal_state(base_uri, power_cycle_iteration):
    """
    Polls the target for status and returns the status to the caller.  If the target achieves "ready" or "failed"
    (i.e. a terminal state) the function return immediately.  If not it returns after a fixed time.
    """
    power_cycle_performed = False
    start_time = time.time()

    while (time_from_start := time.time() - start_time) < reboot_timeout_s:
        if power_cycle_iteration.active and not power_cycle_performed and time_from_start > power_cycle_iteration.time:
            print(f"Power cycling after {time_from_start:.2f} seconds.")
            power_cycle_performed = True
            process = subprocess.run(power_cycle_iteration.config.command)
            if process.returncode:
                raise RuntimeError("Unable to power cycle the target.")

        try:
            status = get_status(base_uri)
        except RuntimeError:
            continue

        if status["state"] == "ready" or status["state"] == "failed":
            return status

        time.sleep(0.1)

    return status


def single_update(base_uri, power_cycle_iteration):
    """Performs a single update cycle.  Throws a RuntimeError on any failure of the update process."""
    set_active_slot()

    status = get_status(base_uri)
    if status["state"] != "ready" and status["state"] != "failed":
        raise RuntimeError(f"Target is in {status['state']} state, should be in ready or failed state.")

    version = get_version_to_use()

    print(f"Current slot versions: {slot_versions}")
    print(f"Updating slot {active_slot} using version {version}.")
    post_update(base_uri, version)
    print("Finished posting update.")
    # Give the target a moment to transition from ready to write_update or rauc_update, before we start checking
    # for the ready state.
    time.sleep(1)
    status = wait_for_terminal_state(base_uri, power_cycle_iteration)

    if status["state"] == "failed":
        raise RuntimeError(f"Update failed with error: {status['last_error']}")
    elif status["state"] != "ready":
        raise RuntimeError(f"Update failed with terminal state of {status['state']}")

    # We confirm the update occurred by checking the build date of the installed firmware and comparing to
    # what we think we installed.
    actual_build_date = get_build_date(base_uri)
    expected_build_date = version_json[version]["build_date"]

    if not power_cycle_iteration.active:
        if actual_build_date != expected_build_date:
            raise RuntimeError(f"After update, expected build of {expected_build_date} but found {actual_build_date}.")
        else:
            slot_versions[active_slot] = version
    else:
        current_build_date = version_json[slot_versions[get_inactive_slot()]]["build_date"]

        # If we power cycled then there are two possibilities.  Either we cycled early enough that
        # the update didn't complete or we did after the update was complete.  Both are valid results.
        if actual_build_date == expected_build_date:
            slot_versions[active_slot] = version
        elif actual_build_date == current_build_date:
            # If the update didn't complete make sure the next update attempt will use the same slot.
            # That makes it easier to track in the console output.
            set_active_slot()
        else:
            raise RuntimeError(
                (
                    f"After power cycle, expected build of {current_build_date}"
                    f" or {expected_build_date} but found {actual_build_date}."
                )
            )


def multiple_udpates(base_uri, count, power_cycle_config):
    for ii in range(count):
        print(f"----- Test iteration {ii} -----")

        power_cycle_iteration = PowerCycleIteration(power_cycle_config)

        rand_val = random.randint(0, 100)
        power_cycle_iteration.active = (
            # Only power cycle after the first two updates so we know exactly what to expect in those slots.
            ii >= 2
            and power_cycle_config.enable
            and power_cycle_config.percent > 0
            and rand_val <= power_cycle_config.percent
        )

        time_diff = power_cycle_config.time_range[1] - power_cycle_config.time_range[0]
        power_cycle_iteration.time = power_cycle_config.time_range[0] + random.random() * time_diff

        single_update(base_uri, power_cycle_iteration)

        print(f"Test iteration {ii} successful.")


def read_updates(work_dir):
    """Transfers the three update bundles and version files from disk into memory."""
    for ii in range(0, 3):
        with open(f"{work_dir}/{ii}.update.raucb", "rb") as f:
            updates[ii] = f.read()

        with open(f"{work_dir}/{ii}.version.json", "r") as f:
            version_json[ii] = json.loads(f.read())


def test_connection(base_uri):
    try:
        get_status(base_uri)
    except RuntimeError:
        return False

    return True


@click.command()
@click.option(
    "-t", "--target_ip", default="192.168.0.10", show_default=True, help="IP of the target; no port needs to be given."
)
@click.option("-n", "--num", default=10, show_default=True, help="Number of updates to perform.")
@click.option(
    "-c",
    "--clean",
    default=False,
    show_default=True,
    is_flag=True,
    help="If a working dir is given, whether to clean any build and output artifacts.",
)
@click.option(
    "-w",
    "--work-dir",
    help="Where the build and output artifacts should be stored. If not given a temp directory will be created.",
)
@click.option(
    "-p",
    "--power-cycle",
    default=False,
    show_default=True,
    is_flag=True,
    help="Whether to enable power cycling the target during updates.",
)
@click.option(
    "--power-cycle-percent",
    default=30,
    show_default=True,
    type=click.IntRange(0, 100),
    help="What (approximate) percent of iterations we should power cycle.",
)
@click.option(
    "--power-cycle-time-range",
    default=[0, 10],
    show_default=True,
    type=click.FLOAT,
    nargs=2,
    help="The range of times used when randomly selecting the power cycle time after the update has been transmitted.",
)
@click.option(
    "--power-cycle-command",
    default="./power_cycle.sh",
    show_default=True,
    help="Command passed to subprocess.run() to execute the power cycle.",
)
def update(
    target_ip, num, clean, work_dir, power_cycle, power_cycle_percent, power_cycle_time_range, power_cycle_command
):
    """Tests the update mechanism."""
    if work_dir is None:
        work_dir = mkdtemp()
        print(f"Creating working directory: {work_dir}")
    elif not os.path.isdir(work_dir):
        print(f"Creating working directory: {work_dir}")
        os.makedirs(work_dir)

    base_uri = f"http://{target_ip}:{target_port}"
    connected = test_connection(base_uri)
    if not connected:
        print("Cannot connect to the target.  Make sure it is powered on and network connected.")
        sys.exit(1)

    print("Calling the script to prepare the working directory.")

    prepare_cmds = ["/bin/bash", "prepare.sh", work_dir]
    if clean:
        prepare_cmds.append("-c")

    process = subprocess.run(prepare_cmds)
    if process.returncode:
        print(f"Prepare script failed with exit code: {process.returncode}")
        sys.exit(1)

    read_updates(work_dir)

    power_cycle_config = PowerCycleConfig(
        enable=power_cycle, percent=power_cycle_percent, time_range=power_cycle_time_range, command=power_cycle_command
    )

    multiple_udpates(base_uri, num, power_cycle_config)

    print(f"Script complete. Artifacts in {work_dir}")


if __name__ == "__main__":
    update()

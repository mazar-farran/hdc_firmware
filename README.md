# dashcam

## Dependencies
Refer to the Buildroot manual for 
[required and optional dependencies](https://buildroot.org/downloads/manual/manual.html#requirement).

To add to that:

### Required
* `git`

### Optional
* `cmake` - Although Buildroot will build cmake if necessary it optimizes by using the CMake
on the host system if the version is recent enough.  Using the host CMake can save 5+ minutes
in rebuild time.

* `qt5` - This is packaged as `qt5-default` on Ubuntu 20.  This allows bringing up a better UI
interface when running `make xconfig`.

* `curl` - Necessary to use the `update_http.sh` script.

* `jq` - Necessary to use the `flash_resize_image.sh` and `update_http.sh` scripts.

## Getting Started

1. Clone the top-level dashcam repository with submodules.
    ```
    git clone --recurse-submodules https://github.com/cshaw9-rtr/dashcam.git
    cd dashcam
    ``` 

2. Setup a target build.  The config files are setup to build both 32-bit and 64-bit images, 
though the camera SW only supports 32-bit at the moment so that is preferred.
    ```
    make -C buildroot/ BR2_EXTERNAL=../dashcam O=../output raspberrypicm4io_dashcam_defconfig
    ```
    Alternately use `raspberrypicm4io_64_dashcam_defconfig` for the 64-bit build.

3. Perform the build.  With no ccache a rebuild should take about 30-40 minutes.
    ```
    cd output
    make
    ```

4. Install the image on the target using your preferred method.  `images/sdcard.img` is a full disk 
image suitable for flashing.  For the CM4IO target, to flash you need the pin jumper and a 
connection to the target's USB flashing port.  The commands to install the bootloader,
flash the device, and resize the final data partition have all been collected into a
script.  Relative to the `output` directory and assuming the device will mount to `/dev/sda`, run:
    ```
    ../scripts/flash_resize_image.sh sda
    ```
    This script has basic safety checks that the target is connected to the given device (e.g. `sda`),
    and is in fact a Raspberry Pi!
    
5. After flashing the full disk image, changes to the image can use over-the-air updates.  

    **The preferred method** for doing updates is the production method using the
    onboard updater over http.  A script is provided to perform the update from the host.
    Relative to the `output` directory and assuming a target IP address, run:
    ```
    ../scripts/update_http.sh 192.168.1.10
    ```
    You should see the update progress in the console and the target will reboot.  When it comes
    up again it will display the version info of the new image.

    During development, we also support a mode that leaves SSH open to a root user with no
    password.  A script is also provided for this method:
    ```
    ../scripts/update_ssh.sh 192.168.1.10
    ```

## Working With the Target

### Getting a Console
Right now all builds are in development mode, which provides a root user with no password.  You can 
get a console to the target using one of the following:
1. Use the virtual terminal.  We run a getty session on TTY1.  Just connect an HDMI monitor and USB 
keyboard.
2. Use the GPIO pins.  We run a serial console on UART0 and you can use a USB-to-GPIO cable as 
discussed [here](https://elinux.org/RPi_Serial_Connection).  You can see the CM4IO pinout 
[here](https://pi4j.com/1.3/pins/rpi-cm4.html), of which you use pins 6,8,10.
3. Use SSH.  You can connect using the root user with no password.

### Networking
The target uses both wired ethernet and wifi interfaces.
* On the wired ethernet interface the target is a DHCP client.  The target gets an IP address on the wired 
ethernet adapter from the an external DHCP server (which you have to provide if one isn't already on the LAN).
* On the wifi interface the target is an access point.  It sets a static IP address of `192.168.0.10` 
for itself and runs a DHCP server that assigns addresses in the `192.168.0.[11-50]` range.  The
wifi SSID is `dashcam` and the password is `hivemapper`.

## Troubleshooting

### How Do I Find The Target's IP Address?
If you connect to the target using wifi see the Networking section for the target's static IP address.


If you connect using the wired ethernet interface then the target will have an IP address assigned
by the LAN's DHCP server.  If you have a console session on the target, then you 
can run `ip addr`.  If you don't have a working console, you can search for the target on your 
subnet using `arp-scan`.  For example, on a `192.168.1.xxx` subnet LAN:
```
sudo arp-scan 192.168.1.0/24
```
The target will likely show up as `(Unknown)`.

### My USB keyboard doesn't work in the virtual console
Make sure you've unplugged the USB cable from the USB flashing port.  That seems to messup the use 
of a USB keyboard.

### Remote Host Identification Error
If you are using SSH to the target (like when using the `update_ssh.sh` script) you may get an
error that starts:
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```
This is because the SSH keys have changed on the target and to your host the target at the IP
address looks like it has changed.  SSH keys for the target are generated on a full rebuild,
so that's likely why they have changed.

The error message has the solution: run the `ssh-keygen` command with the `-R` option.  For me:
```
ssh-keygen -f "/home/cshaw/.ssh/known_hosts" -R "192.168.1.10"
```

## Developing in the Dashcam Project

### Updating the Capable Robot Camera Software
1. Changes are pulled in from the Capable Robot repo, so changes in the camera software first need to 
be pushed to the camera repo GitHub.  The change itself doesn't need to be in the main branch,
it just needs a hash.

2. The hash needs to be modified in the [camera-cpp.mk](./dashcam/package/camera-cpp/camera-cpp.mk)
file and the [camera-zig.mk](./dashcam/package/camera-zig/camera-zig.mk) files.  Since the camera
SW has two different build systems in the same tree we build it as two separate projects but

3. From the `output` directory, run `make`.

### Updating the RPi `config.txt` file.
`config.txt` for each target is modified from the default.  For example, you can find one target
version [here](./dashcam/board/raspberrypi/config_cm4io.txt).  If you modify that, then from
the `output` directory:
```
rm -rf build/rpi-firmware*
make
# After the build finishes you can confirm your changes by:
cat images/rpi-firmware/config.txt
```

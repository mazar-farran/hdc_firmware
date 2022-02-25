# dashcam

## Getting Started

1. Clone the top-level dashcam repository with submodules.
    ```
    git clone --recurse-submodules https://github.com/cshaw9-rtr/dashcam.git
    cd dashcam
    ``` 

2. Setup a target build.  The config files are setup to build both 32-bit and 64-bit images, though the camera SW only supports 32-bit at the moment so that is preferred.
    ```
    make -C buildroot/ BR2_EXTERNAL=../dashcam O=../output raspberrypicm4io_dashcam_defconfig
    ```
    Alternately use `raspberrypicm4io_64_dashcam_defconfig` for the 64-bit build.

3. Perform the build.  With no ccache a rebuild should take about 30-40 minutes.
    ```
    cd output
    make
    ```

4. Install the image on the target using your preferred method.  `images/sdcard.img` is a full disk image suitable for flashing.  For the CM4IO target, to flash you need the pin jumper and a connection to the target's USB flashing port.  The commands I use (use the correct device on your host):
    ```
    # I still need sudo even though I'm a member of plugdev.
    sudo host/bin/rpiboot
    # Substitute the correct host device (on my system it is /dev/sda).
    sudo umount /dev/sdX
    sudo dd if=images/sdcard.img of=/dev/sda status=progress oflag=direct bs=4M conv=fsync
    ```
    Remove the jumper and power cycle the target.

5. After flashing the full disk image, changes to the image can use over-the-air updates.  Currently we support a development mode that leaves SSH open to a root user with no password.  A script is provided to perform the update from the host.  Relative to the `output` directory and assuming a target IP address, run:
    ```
    ../scripts/update_ssh.sh 192.168.1.10
    ```
    You should see the update progress in the console and the target will reboot.

## Working With the Target
### Getting a Console
Right now all builds are in development mode, which provides a root user with no password.  You can get a console to the target using one of the following:
1. Use the virtual terminal.  We run a getty session on TTY1.  Just connect an HDMI monitor and USB keyboard.
2. Use the GPIO pins.  We run a serial console on UART0 and you can use a USB-to-GPIO cable as discussed [here](https://elinux.org/RPi_Serial_Connection).  You can see the CM4IO pinout [here](https://pi4j.com/1.3/pins/rpi-cm4.html), of which you use pins 6,8,10.
3. Use SSH.  You can connect using the root user with no password.

## Troubleshooting

### How Do I Find The Target's IP Address?
The target gets an IP address from the an external DHCP server (which you have to provide if one isn't already on the LAN).  If you have a console, then you can run `ip addr`.    If you don't have a working console, you can search for the target on your subnet using `arp-scan`.  For example, on a `192.168.1.xxx` subnet:
```
sudo arp-scan 192.168.1.0/24
```
The target will likely show up as `(Unknown)`.

### My USB keyboard doesn't work in the virtual console
Make sure you've unplugged the USB cable from the USB flashing port.  That seems to messup the use of a USB keyboard.



#!/bin/sh

# Debug/test functionality to make sure all associated
# services can go down and back up.

touch /tmp/results.txt
echo "Switching to P2P" >> /media/usb0/results.txt
sh /opt/dashcam/bin/switch_P2P.sh >> /media/usb0/results.txt
sleep 15
echo "Switching back" >> /media/usb0/results.txt
sh /opt/dashcam/bin/switch_AP.sh >> /media/usb0/results.txt

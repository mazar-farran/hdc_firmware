#!/bin/sh

# Debug/test functionality to make sure all associated
# services can go down and back up.

resultFile="/mnt/data/wifi_results.txt"

if [ -z "$1" ]
then
  echo "You need to provide a MAC Address for the device!"
  exit -1
fi

touch $resultFile
echo "Switching to P2P" >> $resultFile
sh /opt/dashcam/bin/network/wifi_switch_P2P.sh >> $resultFile
sleep 5
echo "Looking for your phone" >> $resultFile
sh /opt/dashcam/bin/network/wifi_P2Pconnect_sel.sh $1 >> $resultFile
sleep 5
if [ -f "/tmp/CONNECT_SUCCESS" ]
then
  echo "Success!" >> $resultFile
else
  echo "Failed! Switching back" >> $resultFile
  sh /opt/dashcam/bin/network/switch_AP.sh >> $resultFile
fi


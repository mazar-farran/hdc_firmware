#!/bin/sh

# Debug/test functionality to make sure all associated
# services can go down and back up.

resultFile="/mnt/data/WifiDirRes.txt"

touch $resultFile
echo "Switching to P2P" >> $resultFile
sh /opt/dashcam/bin/switch_P2P.sh >> $resultFile
sleep 5
echo "Looking for your phone" >> $resultFile
sh /opt/dashcam/bin/P2P_connect_nocheck.sh >> $resultFile
sleep 5
if [ -f "/tmp/CONNECT_SUCCESS" ]
then
  echo "Success!" >> $resultFile
else
  echo "Failed! Switching back" >> $resultFile
  sh /opt/dashcam/bin/switch_AP.sh >> $resultFile
fi


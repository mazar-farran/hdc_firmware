#!/bin/sh

# This does a p2p connection, but doesn't check for 
# a particular mac address. Instead it connects to any that is available

wpa_cli -i wlan0 set config_methods virtual_push_button
wpa_cli -i wlan0 p2p_find

connected=0
con_addr=""

for CHECK in 1 2 3 4 5 6 7 8 9 10
do
  probe_result=$(wpa_cli -i wlan0 p2p_peers) 
  echo "Finding a match..."
  for result in $probe_result
  do
    echo "Connecting to $result"
    connect_result=$(wpa_cli -i wlan0 p2p_connect $1 pbc)
    if [ $connect_result == "FAIL" ]
    then
      echo "Failed to connect. Retrying..."
    else
      echo "Success!"
      connected=1
      con_addr=$result
      break
    fi    
  done
  if [ $connected eq 0 ]
  then
    echo "Retrying..."
    sleep 3
  else
    break
  fi
done
if [ $connected eq 1 ]
then  
  echo "Connected to $con_addr"
fi

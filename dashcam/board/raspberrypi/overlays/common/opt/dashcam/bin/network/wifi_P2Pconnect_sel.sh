#!/bin/sh

# This connects to the device whose MAC Address is provided
# to the script. If none is provided, it exists.

found_result=0

if [ -z "$1" ]
then
  echo "You need to provide a MAC Address for the device!"
fi

wpa_cli -i wlan0 set config_methods virtual_push_button
wpa_cli -i wlan0 p2p_find

for CHECK in 1 2 3 4 5 6 7 8 9 10
do
  probe_result=$(wpa_cli -i wlan0 p2p_peers) 
  echo "Finding a match..."
  for result in $probe_result
  do
    if [ $result == $1 ]
    then
      echo "Match found"
      found_result=1
      break
    fi
  done
  if [ $found_result -eq 1 ]
  then
    break
  fi
  echo "No match found. Waiting and retrying"
  sleep 3
done

if [ $found_result -eq 0 ]
then
  echo "No match. Retry "
else
  for CHECK in 1 2 3 4 5
  do
    connect_result=$(wpa_cli -i wlan0 p2p_connect $1 pbc)
    if [ $connect_result == "FAIL" ]
    then
      echo "Failed to connect. Retrying..."
    else
      echo "Success!"
      wpa_cli -i wlan0 p2p_connect $1 pbc
      break
    fi
    sleep 3
  done
fi

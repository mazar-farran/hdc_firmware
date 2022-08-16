#!/bin/sh

# This brings down the Wifi AP on wlan0 and brings up wifi direct
# Note you will still need to establish a wpa_cli connection

systemctl stop hostapd
systemctl stop wpa_supplicant

cp /opt/dashcam/cfg/P2P_dhcpcd.conf /etc/dhcpcd.conf
cp /opt/dashcam/cfg/P2P_dnsmasq.conf /etc/dnsmasq.conf

wpa_supplicant -Dnl80211 -iwlan0 -c/etc/wpa_supplicant.conf &
systemctl restart systemd-networkd

rm /opt/dashcam/network-mode.txt
echo "P2P" > /opt/dashcam/network-mode.txt

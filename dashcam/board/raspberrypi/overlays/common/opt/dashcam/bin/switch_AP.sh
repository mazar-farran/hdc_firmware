#!/bin/sh

# This brings down any wifi-direct configuration and brings up
# the original Access point configuration.

killall -9 wpa_supplicant
systemctl stop hostapd
systemctl stop dhcpcd
systemctl stop dnsmasq

cp /opt/dashcam/cfg/AP_dhcpcd.conf /etc/dhcpcd.conf
cp /opt/dashcam/cfg/AP_dnsmasq.conf /etc/dnsmasq.conf

systemctl restart systemd-networkd
systemctl restart hostapd
systemctl restart dhcpcd
systemctl restart dnsmasq

rm /opt/dashcam/network-mode.txt
echo "AP" > /opt/dashcam/network-mode.txt

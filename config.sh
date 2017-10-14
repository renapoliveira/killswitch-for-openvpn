#!/bin/bash

#interface used for the internet connection (eth0, wlan0, etc)
INTERFACE=

#Name of the tunnel interface used to route VPN packets (tun0, tun1, etc)
TUNNEL=

#Full path of the VPN(.ovpn) file. Make sure to configure your credentials properly inside this file, so, when the script reconnects, openvpn will not need to ask for your credentials
VPN_FILE=

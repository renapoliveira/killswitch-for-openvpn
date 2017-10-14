#!/bin/bash
source config.sh
trap ctrl_c INT

function ctrl_c() {
	echo "Flushing iptables and exiting"
	iptables --flush
	exit 1
}

iptables --flush
#Allow connection with the VPN IP
iptables -A OUTPUT -d $IP -j ACCEPT
iptables -A INPUT -s $IP -j ACCEPT
#Allow connection through the tunnel
iptables -A OUTPUT -o $TUNNEL -j ACCEPT
iptables -A INPUT -i $TUNNEL -j ACCEPT
#Block all connection through the main interface
iptables -A OUTPUT -o $INTERFACE -j DROP
iptables -A INPUT -i $INTERFACE -j DROP

#Check every 5 seconds if VPN goes down, then reconnect it
while [ true ]
do
	if [[ $(nmcli connection) != *$TUNNEL* ]]; then
		openvpn $VPN_FILE
	fi
	sleep 5
done


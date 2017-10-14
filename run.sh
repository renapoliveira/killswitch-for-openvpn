#!/bin/bash

#Import config file
source config.sh

#Get the VPN IP from the VPN file
IP=$(cat $VPN_FILE | grep "remote " | awk '{print $2}')

trap ctrl_c INT

#Check root permission
if test " `id -u`" != " 0"
then
    echo "permission denied (use sudo)"
    exit 1
fi

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

#Check every 20 seconds if VPN goes down, then reconnect it
while [ true ]
do
	if [[ $(nmcli connection) != *$TUNNEL* ]]; then
		#Kill older openvpn processes to avoid creating new tunnels
		kill `ps -ef | grep $VPN_FILE | grep -v "grep" | awk '{print $2}'`
		#Start openvpn
		openvpn $VPN_FILE &
	else
		echo "connected"
	fi
	sleep 20
done


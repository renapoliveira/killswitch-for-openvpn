#!/bin/bash

#Import config file
source config

#Get the VPN IP from the VPN file
IP=$(cat $VPN_FILE | grep "remote " | awk '{print $2}')

trap ctrl_c INT

#Check root permission
check_permission() {
	if test " `id -u`" != " 0"
	then
	    echo "permission denied (use sudo)"
	    exit 1
	fi
}

function ctrl_c() {
	echo "Flushing iptables and exiting"
	iptables --flush
	exit 1
}

set_firewall_rules() {
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
}

reconnect() {
	#Kill older openvpn processes to avoid creating new tunnels
	kill `ps -ef | grep $VPN_FILE | grep -v "grep" | awk '{print $2}'` > /dev/null 2>&1
	#Start openvpn
	openvpn $VPN_FILE & 
}

#Check every 20 seconds if VPN goes down, then reconnect it
check_connection() {
	while [ true ]
	do
		if [[ $(nmcli connection) != *$TUNNEL* ]]; then
			reconnect
		fi
		sleep 20
	done
}

check_permission
set_firewall_rules
check_connection

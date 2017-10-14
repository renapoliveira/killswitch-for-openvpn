#!/bin/bash
trap ctrl_c INT
VPN_FILE=$1

check_permission() {
	if test " `id -u`" != " 0"
		then
		echo "permission denied (use sudo)"
		exit 1
	fi
}

check_argument() {
	if [ -z $VPN_FILE ]
		then
		echo "First argument must be VPN file(.ovpn)"
		exit 1
	fi
}

config() {	
	#Get the default network interface
	echo "Detecting your default network interface..."
	INTERFACE=`route | grep '^default' | grep -o '[^ ]*$'`
	echo "Using "$INTERFACE

	TUNNEL=tun0
	echo "Using interface "$TUNNEL " for VPN, change the script if you need another name."	

	#Get the VPN IP from the VPN file
	echo "Detecting your VPN server address..."
	IP=`cat $VPN_FILE | grep "remote " | awk '{print $2}'`
	echo "Using "$IP
}

function ctrl_c() {
	echo "Flushing iptables and exiting"
	iptables --flush
	exit 1
}

set_firewall_rules() {
	echo "Setting firewall rules"
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
	echo "Reconnecting VPN"
	#Kill older openvpn processes to avoid creating new tunnels
	kill `ps -ef | grep "openvpn $VPN_FILE" | grep -v "grep" | awk '{print $2}'` > /dev/null 2>&1
	#Start openvpn
	openvpn $VPN_FILE & 
}

#Check every 20 seconds if VPN goes down, then reconnect it
check_connection() {
	echo "Check VPN connection"
	while [ true ]
	do
		if [[ $(nmcli connection) != *$TUNNEL* ]]; then
			reconnect
		fi
		sleep 20
	done
}

check_permission
check_argument
config
set_firewall_rules
check_connection

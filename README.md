# killswitch-for-openvpn
A killswitch script with autoconnecting function for OpenVPN

## About

This script performs the following:

-It blocks all traffic through your default network interface, except the communication with the VPN IP ADDRESS, meaning that if the VPn goes down, your traffic will not go through your default interface. 

-It allows full communication through the VPN tunnel interface.

-It reconnects to the VPN tunnel in case it goes down.

## Usage

Give the script execution permission

```shell
chmod +x run.sh
```

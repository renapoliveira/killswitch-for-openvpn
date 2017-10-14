# killswitch-for-openvpn
A killswitch script with autoconnecting function for OpenVPN

## About

This script performs the following:

-It blocks all traffic through your default network interface, except the communication with the VPN IP address, meaning that if the VPN goes down, your traffic will not go through your default interface. 

-It allows full communication through the VPN tunnel interface.

-It reconnects to the VPN tunnel in case it goes down.

## Usage

Give the script execution permission:

```shell
chmod +x run.sh
```

Run the script specifying the full path of your .ovpn file:

```shell
./run.sh /tmp/vpn.ovpn
```

## Notes

-The script is using tun0 as the VPN tunnel interface, if your OS uses a different one, edit the line TUNNEL=tun0 inside the script

-Make sure your authentication details are properly configured within your .ovpn file, so when the VPN is reconnected, there will ne no interaction needed.

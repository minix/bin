#!/bin/sh

usage() {
	echo "Usage: ipmi_reset IPADDR [status|on|off|cycle|reset|diag|soft] "
	exit 1
}
if [ $# -eq 2 ]; then
	/usr/bin/ipmitool -H $1 -U admin -P '56.com_ipmi' power $2
else
	usage
fi

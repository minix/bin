#!/bin/sh

host=$1

if [ $# -ne 3 ]; then
	echo "Usage: adduser.sh IPAddress username ftpdirectory"
	exit 1
fi

ssh -p 32200 ${host} "cd /home/proftpd/etc && ../bin/ftpasswd --passwd --name $2 --gid 99 --uid 99 --shell /sbin/nologin --home $3"

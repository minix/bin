#!/bin/sh

for i in `seq 10 100`
do
	ssh -p 32200 172.16.100.${i} "/sbin/ifconfig -a | grep [eth] | awk '/112\.xx\.xx/{print }'" >> abc.txt
done

#!/bin/sh

i=1
while [ ${i} -le 10 ]
do
	touch `date +%Y%m%d%m%s`.txt
	sleep 1
	i=`expr ${i} + 1`
done

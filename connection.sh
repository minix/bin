#!/bin/sh

host="$1.XXX.com"
path="/home/lighttpd/logs/access.log"

ssh -p 32200 ${host} "tail -10000 ${path} | awk '{print \$7}' | awk -F? '{print \$1}' | sort | uniq -c | sort -nr | head -10 " 

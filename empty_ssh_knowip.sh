#!/bin/sh

sed -i "/^$1/d" /home/minix/.ssh/known_hosts

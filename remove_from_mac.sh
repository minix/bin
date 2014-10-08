#!/bin/sh

remove_mac=$(echo $1 | awk '{gsub(":", ""); print}')

echo ${remove_mac}

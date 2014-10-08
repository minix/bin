#!/bin/sh

usage(){
        echo 'Usages: $0 NO_COLON_OF_MACADDRESS'
        exit 1
}

if [ $# == 1 ]; then
        arr=($(echo $1 | fold -b2))
        echo ${arr[0]}:${arr[1]}:${arr[2]}:${arr[3]}:${arr[4]}:${arr[5]}
else
        usage
fi

#[ $# == 1 ] && { arr=($(echo $1 | fold -b2)); echo ${arr[0]}:${arr[1]}:${arr[2]}:${arr[3]}:${arr[4]}:${arr[5]}; } || { usage; }

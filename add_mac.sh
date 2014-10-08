#!/bin/sh

usage(){
        echo 'Usage: $0 NO_:_MACADDRESS'
        exit 1
}

if [ $# == 1 ]; then
        arr=($(echo $1 | fold -b2))
        echo ${arr[0]}:${arr[1]}:${arr[2]}:${arr[3]}:${arr[4]}:${arr[5]}
else
        usage
fi

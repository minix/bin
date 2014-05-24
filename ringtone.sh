#!/bin/sh

useage()
{
	echo "Usage: $0 Source_music_file Dest_Directory"
}

if [ $# -ne 2 ]; then
	useage
	exit 1
else
	afconvert -f m4af $1 -o $2
fi

#!/bin/bash

FILEPATH="/usr/local/nagios/libexec/dir_size.txt"

if [ -f $FILEPATH ]; then
echo `cat $FILEPATH `
exit 0
else
echo "None"
exit 1
fi


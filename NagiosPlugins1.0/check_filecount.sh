#!/bin/sh

FILEPATH="/usr/local/nagios/libexec/total_files.txt"
if [ -f $FILEPATH ]; then
echo `cat $FILEPATH`
exit 0
else
echo  "None"
exit 1
fi



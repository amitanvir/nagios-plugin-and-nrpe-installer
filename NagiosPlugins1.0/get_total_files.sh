#!/bin/bash

TotalCountFile="/usr/local/nagios/libexec/total_files.txt"
DIR="/var/www/"

if [ -f $TotalCountFile ]; then
rm $TotalCountFile
fi
echo `find $DIR -depth -nowarn -type f | wc -l` >> $TotalCountFile
chown nagios:nagios $TotalCountFile
chmod +x $TotalCountFile
exit 0


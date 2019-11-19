#!/bin/bash


DIR="/var/www/"
DIRSIZEFILE="/usr/local/nagios/libexec/dir_size.txt"
divisor=1048576 #GB

if [ -f $DIRSIZEFILE ]; then
rm $DIRSIZEFILE
fi
echo `du --max-depth=1 $DIR|tail -1 |awk -v DIVISOR=$divisor '{print $1/DIVISOR " GB"}'` >> $DIRSIZEFILE
chown nagios:nagios $DIRSIZEFILE
chmod +x $DIRSIZEFILE
exit 0


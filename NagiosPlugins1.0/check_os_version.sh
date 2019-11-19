#!/bin/bash

if [ -f /etc/lsb-release ]; then
echo `cat /etc/lsb-release`
elif [ -f /etc/redhat-release ]; then
echo `cat /etc/redhat-release`
elif [ -f /etc/issue.net ]; then
echo `cat /etc/issue.net`
elif [ -f /etc/distro-release ]; then
echo `cat /etc/distro-release`
else
 echo "Error occurred"
fi


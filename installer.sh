#!/bin/bash

########################################################
### This script is created by Tanvir Islam <knock@amitanvir.info>.
########################################################

echo "Debian Packages are going for upgradation from repository list"
apt-get update && apt-get upgrade
apt-get install build-essential
echo "Packages are updated"
echo "............"
echo "GCC Version-"
gcc -v
echo "Make Version-"
make -v
echo "Adding Nagios user..."
useradd nagios
echo "Enter Nagios account password"
passwd nagios
echo "vbox user password is updated"
echo "---------------------------------------"
echo "Installing Nagios Plugin Version-2.2.1"
cd /tmp
#wget https://www.nagios-plugins.org/download/nagios-plugins-1.5.tar.gz
wget https://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz
tar -xzvf nagios-plugins-*.tar.gz
cd nagios-plugins-*
echo "Installing Libsll Package"
apt-get install libssl-dev
echo "Libssl Package installed"
make
make install
chown nagios:nagios /usr/local/nagios
chown -R nagios:nagios /usr/local/nagios/libexec
echo "Nagios Plugin Installation complete"
echo "Installing Xinetd Package"
apt-get install xinetd
echo "Xinetd Package installed"
echo "---------------------------------------"
echo "Installing Nagios Remote Plugin Executor {NRPE} Version-3.2.1"
cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz
tar -xzvf nrpe-*.tar.gz
cd nrpe-*
./configure
make all
make install-plugin
make install-daemon
make install-daemon-config
make install-xinetd
read -p "Enter Nagios Monitor Server IP Address: " nagiosmonitorip
mv /etc/xinetd.d/nrpe /etc/xinetd.d/nrpe.bak
sed 's/127.0.0.1.*/127.0.0.1 '"$nagiosmonitorip"'/g' /etc/xinetd.d/nrpe.bak > /etc/xinetd.d/nrpe
echo "nrpe            5666/tcp                        # NRPE" >> /etc/services
/etc/init.d/xinetd restart
echo "I Hope It will be working"
rm installer.sh

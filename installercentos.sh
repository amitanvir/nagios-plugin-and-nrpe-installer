#!/bin/bash
########################################################
### This script is created by Tanvir Islam <knock@amitanvir.info>.
########################################################
echo "Packages are going for upgradation from repository list"
yum update -y
yum install perl-Sys-Statistics-Linux dmidecode -y
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
yum install openssl-devel -y
yum groupinstall 'Development Tools' -y
echo "Libssl Package installed"
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install
chown nagios:nagios /usr/local/nagios
chown -R nagios:nagios /usr/local/nagios/libexec
echo "Nagios Plugin Installation complete"
echo "Installing Xinetd Package"
yum install xinetd -y
echo "Xinetd Package installed"
echo "---------------------------------------"
echo "Installing Nagios Remote Plugin Executor {NRPE} Version-3.2.1"
cd /tmp
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-3.2.1/nrpe-3.2.1.tar.gz
#wget https://github.com/amitanvir/nagios-plugin-and-nrpe-installer/raw/master/nrpe-2.12.tar.gz
#wget https://github.com/NagiosEnterprises/nrpe/archive/nrpe-2-12.tar.gz
tar -xzvf nrpe-*.tar.gz
cd nrpe-nrpe-*
ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/libssl.so
./configure --enable-ssl
make all
make install-plugin
make install-daemon
make install-daemon-config
make install-xinetd
read -p "Enter Nagios Monitor Server IP Address: " nagiosmonitorip
mv /etc/xinetd.d/nrpe /etc/xinetd.d/nrpe.bak
sed 's/127.0.0.1.*/127.0.0.1 '"$nagiosmonitorip"'/g' /etc/xinetd.d/nrpe.bak > /etc/xinetd.d/nrpe
echo "nrpe            5666/tcp                        # NRPE" >> /etc/services
cd /tmp
wget http://dl.fedoraproject.org/pub/epel/6/i386/Packages/e/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release*rpm
yum install perl-Sys-Statistics-Linux -y
/etc/init.d/xinetd restart
echo "I Hope It will be working"

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
echo "Installing EPEL (Extra Packages for Enterprise Linux) Repository"
yum install epel-release
echo "EPEL Repository installed"
echo "Installing NRPE Package"
yum install nrpe -y
echo "NRPE Package installed"
echo "Installing NRPE Package"
yum install perl-Sys-Statistics-Linux -y
echo "NRPE Package installed"
systemctl start nrpe
systemctl enable nrpe
firewall-cmd --permanent --add-service=nrpe
firewall-cmd --add-service=nrp
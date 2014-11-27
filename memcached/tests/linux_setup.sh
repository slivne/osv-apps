#!/bin/bash
echo start >> /tmp/boot
echo "installing wget gcc" `uptime` >> /tmp/boot 
yum update -y
yum install -y wget
yum install -y gcc
cd /tmp
mkdir a
cd a
echo "Downloading " `uptime` >> /tmp/boot 
wget https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
tar xzvf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure
make 
make install
ldconfig /usr/local/lib
cd ..
wget http://memcached.org/latest
tar -zxvf latest
cd memcached-1.4.??
./configure 
make
make test
make install
echo "Starting memcached " `uptime` >> /tmp/boot
PATH="$PATH:/usr/local/bin"
nohup memcached -u root -t 1 -m 4096 &
echo end >> /tmp/boot
echo `uptime` >> /tmp/boot

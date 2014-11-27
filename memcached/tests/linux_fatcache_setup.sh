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
wget http://fatcache.googlecode.com/files/fatcache-0.1.1.tar.gz
tar xvf fatcache-0.1.1.tar.gz
cd fatcache-0.1.1
./configure 
make
make install
echo "Starting memcached " `uptime` >> /tmp/boot
PATH="$PATH:/usr/local/bin"
# support for detecting all SSD devices is missing assuming it is /dev/xvdb
nohup fatcache --ssd-device=/dev/xvdb --max-index-memory=64 --max-slab-memory=4032 &
echo end >> /tmp/boot
echo `uptime` >> /tmp/boot

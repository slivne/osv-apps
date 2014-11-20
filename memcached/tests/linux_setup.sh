"#!/bin/bash
echo start >> /tmp/boot
yum update -y
yum install -y wget
yum install -y gcc
cd /tmp
mkdir a
cd a
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
nohup memcached -u root -t 1 -m 4048&
echo end >> /tmp/boot"

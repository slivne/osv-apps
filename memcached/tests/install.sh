#!/bin/bash
set -e

tests_dir=${0%/*}

cd $tests_dir

if [ `uname -a | grep Ubuntu | wc -l` = 1 ]; then
   sudo apt-get install -y libevent-dev 
else
   sudo yum install -y libevent-devel
fi

if [ ! -e /usr/local/bin/memaslap ] && [ ! -e /usr/bin/memaslap ] ; then 
   wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
   tar xvf libmemcached-1.0.18.tar.gz
   cd libmemcached-1.0.18
#   ./configure
   ./configure --enable-memaslap
   sudo make install -e LDFLAGS="-L/lib64 -lpthread" 
   cd ..
fi
sudo ldconfig /usr/local/lib

../../tester/generic/install.sh
cat ../../tester/generic/setenv.sh > setenv.sh

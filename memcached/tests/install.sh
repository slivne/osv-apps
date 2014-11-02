#!/bin/bash
set -e

tests_dir=${0%/*}

cd $tests_dir

if [ ! -e /usr/local/bin/memslap ]; then 
   wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
   tar xvf libmemcached-1.0.18.tar.gz
   cd libmemcached-1.0.18
   ./configure
#   ./configure --enable-memaslap
   sudo make install 
   cd ..
fi
sudo ldconfig /usr/local/lib

../../tester/generic/install.sh
cat ../../tester/generic/setenv.sh > setenv.sh

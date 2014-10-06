#!/bin/bash

if [ `memaslap -h | wc -l` -gt 1 ]  
    then  
       echo "already installed"
       exit 0
fi

FILE=libmemcached-1.0.18.tar.gz
URL="https://launchpad.net/libmemcached/1.0/1.0.18/+download/$FILE"

wget $URL
tar xvf  $FILE

cd libmemcached-1.0.18
./configure
make


#!/bin/sh

# Build a directory from the upstream redis 
set -e

VERSION=3.0.0-beta3
mkdir upstream
cd upstream
wget https://github.com/antirez/redis/archive/$VERSION.tar.gz
tar zxvf $VERSION.tar.gz
mv redis-$VERSION redis
cd redis
make


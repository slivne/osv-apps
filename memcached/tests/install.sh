#!/bin/bash
set -e

tests_dir=${0%/*}

cd $tests_dir

sudo yum install -y libmemcached

../../tester/generic/install.sh
cat ../../tester/generic/setenv.sh >! tests/setenv.sh

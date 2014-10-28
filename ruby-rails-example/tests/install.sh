#!/bin/bash -xvf
set -e

tests_dir=${0%/*}

cd $tests_dir/../../tester/tool/wrk

./install.sh

cp setenv.sh $tests_dir/setenv.sh

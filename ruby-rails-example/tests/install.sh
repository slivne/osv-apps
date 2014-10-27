#!/bin/bash -xvf
set -e

tests_dir=${0%/*}

cd $tests_dir
cwd_save=`pwd`

cd ../../tester/tool/wrk

./install.sh

cp setenv.sh $cwd_save/setenv.sh

#!/bin/bash -xvf
set -e

tests_dir=${0%/*}

$tests_dir/../../tester/tools/wrk/install.sh
cp $tests_dir/../../tester/tools/wrk/setenv.sh $tests_dir/setenv.sh


#!/bin/bash
set -e

tests_dir=${0%/*}

cd $tests_dir
echo export GENERIC_ROOT=`pwd`> setenv.sh

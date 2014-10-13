#!/bin/bash
set -e

tests_dir=${0%/*}

cd $tests_dir/..

wget https://github.com/downloads/brianfrankcooper/YCSB/ycsb-0.1.4.tar.gz
tar xfvz ycsb-0.1.4.tar.gz

make upstream/apache-cassandra-2.1.0

chmod +x upstream/apache-cassandra-2.1.0/tools/bin/*

echo export CASSANDRA_CLI="`pwd`/upstream/apache-cassandra-2.1.0/bin/cassandra-cli" > tests/setenv.sh
echo export CASSANDRA_STRESS="`pwd`/upstream/apache-cassandra-2.1.0/tools/bin/cassandra-stress" >> tests/setenv.sh
echo export YCSB_ROOT="`pwd`/ycsb-0.1.4" >> tests/setenv.sh

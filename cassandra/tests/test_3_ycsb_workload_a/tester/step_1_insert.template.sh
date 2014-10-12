#!/bin/bash
set -e

echo "drop keyspace usertable;" | $CASSANDRA_CLI -h $$sut.ip

cat > /tmp/setup-ycsb.cql <<EOF
create keyspace usertable with placement_strategy = 'SimpleStrategy' and
strategy_options = {replication_factor:1};
use usertable;
create column family data with compression_options = null;
EOF

$CASSANDRA_CLI -h $$sut.ip -f /tmp/setup-ycsb.cql

$YCSB_ROOT/bin/ycsb load cassandra-10 -threads $$tester.ycsb.load.threads -p operationcount=$$tester.ycsb.load.operationcount -p recordcount=$$tester.ycsb.recordcount -p hosts=$$sut.ip -P $YCSB_ROOT/workloads/workloada -s 


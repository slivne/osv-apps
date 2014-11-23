#!/bin/bash
set -e

echo "drop keyspace usertable;" | $CASSANDRA_CLI -h $1

cat > /tmp/setup-ycsb.cql <<EOF
create keyspace usertable with placement_strategy = 'SimpleStrategy' and
strategy_options = {replication_factor:1};
use usertable;
create column family data with compression_options = null;
EOF

$CASSANDRA_CLI -h $1 -f /tmp/setup-ycsb.cql

$YCSB_ROOT/bin/ycsb load cassandra-10 -threads $3 -p operationcount=$4 -p recordcount=$5 -p fieldcount=$6 -p requestdistribution=$7 -p hosts=$1 -P $YCSB_ROOT/workloads/$2 -s 


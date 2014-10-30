#!/bin/bash
set -e
$CASSANDRA_STRESS write n=10 -node 192.168.122.89 -rate threads=10
$CASSANDRA_STRESS read n=10 -node 192.168.122.89 -rate threads=10

$GENERIC_ROOT/rest/base.sh 192.168.122.89

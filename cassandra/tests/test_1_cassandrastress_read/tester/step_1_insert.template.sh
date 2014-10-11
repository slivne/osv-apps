#!/bin/bash
set -e
$CASSANDRA_STRESS write n=$tester_cassandra-stress-read_load -node $sut_ip -rate threads=50

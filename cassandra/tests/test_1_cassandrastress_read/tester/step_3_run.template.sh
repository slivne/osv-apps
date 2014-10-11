#!/bin/bash
set -e
$CASSANDRA_STRESS read n=$tester_cassandra-stress-read_run_requests -node $sut_ip -rate threads=50

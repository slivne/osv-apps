#!/bin/bash
set -e
../../../upstream/current/tools/bin/cassandra-stress read n=$tester-cassandra-stress-read_run_requests -node $sut_ip -rate threads=50

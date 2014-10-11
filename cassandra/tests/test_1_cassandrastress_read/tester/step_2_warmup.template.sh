#!/bin/bash
set -e
../../../upstream/current/tools/bin/cassandra-stress read n=$tester_cassandra-stress-read_warmup_requests -node $sut_ip -rate threads=50
../../../upstream/current/tools/bin/cassandra-stress read n=$tester_cassandra-stress-read_warmup_requests -node $sut_ip -rate threads=50
../../../upstream/current/tools/bin/cassandra-stress read n=$tester_cassandra-stress-read_warmup_requests -node $sut_ip -rate threads=50
../../../upstream/current/tools/bin/cassandra-stress read n=$tester_cassandra-stress-read_warmup_requests -node $sut_ip -rate threads=50

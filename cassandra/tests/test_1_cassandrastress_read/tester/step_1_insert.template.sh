#!/bin/bash
set -e
../../../upstream/current/tools/bin/cassandra-stress write n=$tester_cassandra-stress-read_load -node $sut_ip -rate threads=50

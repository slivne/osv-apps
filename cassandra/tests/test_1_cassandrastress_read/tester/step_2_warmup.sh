#!/bin/bash
set -e
../../../upstream/current/tools/bin/cassandra-stress read n=100000 -node 192.168.122.89 -rate threads=50
../../../upstream/current/tools/bin/cassandra-stress read n=100000 -node 192.168.122.89 -rate threads=50
../../../upstream/current/tools/bin/cassandra-stress read n=100000 -node 192.168.122.89 -rate threads=50
../../../upstream/current/tools/bin/cassandra-stress read n=100000 -node 192.168.122.89 -rate threads=50

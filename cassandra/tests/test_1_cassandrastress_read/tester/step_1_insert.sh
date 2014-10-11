#!/bin/bash
set -e
../../../upstream/current/tools/bin/cassandra-stress write n=100000 -node 192.168.122.89 -rate threads=50

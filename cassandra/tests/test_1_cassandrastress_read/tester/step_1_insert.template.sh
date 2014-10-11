#!/bin/bash
set -e
../../../upstream/current/tools/bin/cassandra-stress write n=100000 -node $sut_ip -rate threads=50

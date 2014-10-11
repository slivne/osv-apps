#!/bin/bash
set -e
../../upstream/current/tools/bin/cassandra-stress read n=100000 -node $sut_ip -rate threads=50

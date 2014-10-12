#!/bin/bash
set -e
$CASSANDRA_STRESS read n=$$tester.cassandra-stress-read.run.requests -node $$sut.ip -rate threads=50

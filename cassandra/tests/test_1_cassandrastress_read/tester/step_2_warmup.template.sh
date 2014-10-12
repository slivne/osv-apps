#!/bin/bash
set -e
$CASSANDRA_STRESS read n=$$tester.cassandra-stress-read.warmup.requests -node $$sut.ip -rate threads=50
$CASSANDRA_STRESS read n=$$tester.cassandra-stress-read.warmup.requests -node $$sut.ip -rate threads=50
$CASSANDRA_STRESS read n=$$tester.cassandra-stress-read.warmup.requests -node $$sut.ip -rate threads=50
$CASSANDRA_STRESS read n=$$tester.cassandra-stress-read.warmup.requests -node $$sut.ip -rate threads=50

#!/bin/bash
set -e
$CASSANDRA_STRESS write n=$$tester.cassandra-stress-read.load -node $$sut.ip -rate threads=50

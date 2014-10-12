#!/bin/bash
set -e
$CASSANDRA_STRESS write n=500000 -node $$sut.ip -rate threads=50

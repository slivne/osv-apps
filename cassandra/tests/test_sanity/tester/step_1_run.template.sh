#!/bin/bash
set -e
$CASSANDRA_STRESS write n=10 -node $$sut.ip -rate threads=10
$CASSANDRA_STRESS read n=10 -node $$sut.ip -rate threads=10

$GENERIC_ROOT/rest/base.sh $$sut.ip

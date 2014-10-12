#!/bin/bash
set -e
STARTTIME=$(date +%s)
let ENDTIME=$STARTTIME+60*60*$$tester.duration_in_hours

while [ $(date +%s) -lt $ENDTIME ]; do
    $CASSANDRA_STRESS read n=500000 -node $$sut.ip -rate threads=50
done

#!/bin/bash
set -e
STARTTIME=$(date +%s)
let ENDTIME=$STARTTIME+60*60*$$tester.duration_in_hours

while [ $(date +%s) -lt $ENDTIME ]; do
    $REDIS_BENCHMARK -h $$sut.ip -n 500000 -c 50
done

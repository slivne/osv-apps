#!/bin/bash
set -e

for threads in $$tester.ycsb.run.threads ; do
   echo "threads : $threads"
   iteration=0
   while [ $iteration -lt $$tester.ycsb.run.iterations ];  do
      echo "iteration : $iteration"
      $YCSB_ROOT/bin/ycsb run cassandra-10 -threads $threads -p operationcount=$$tester.ycsb.run.operationcount -p recordcount=$$tester.ycsb.recordcount -p hosts=$$sut.ip -P $YCSB_ROOT/workloads/workloada -s 
      let iteration=$iteration+1
   done
done


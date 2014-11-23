#!/bin/bash
set -e

for threads in $3 ; do
   iteration=0
   while [ $iteration -lt $4 ];  do
      echo "cs>> start"
      echo "cs>> iteration : $iteration"
      echo "cs>> threads : $threads"
      $YCSB_ROOT/bin/ycsb run cassandra-10 -threads $threads -p operationcount=$5 -p recordcount=$6 -p fieldcount=$7 -p maxexecutiontime=$8 -p requestdistribution=$9 -p maxscanlength=$10 -p hosts=$1 -P $YCSB_ROOT/workloads/$2 -s 
      let iteration=$iteration+1
      echo "cs>> end"
   done
done


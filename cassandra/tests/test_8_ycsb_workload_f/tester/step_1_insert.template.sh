#!/bin/bash
set -e
../../test_ycsb_helpers/tester/step_1_insert.sh  $$sut.ip workloadf $$tester.ycsb.load.threads $$tester.ycsb.recordcount $$tester.ycsb.recordcount $$tester.ycsb.fieldcount $$tester.ycsb.requestdistribution 

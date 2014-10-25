#!/bin/bash
set -e
../../test_ycsb_helpers/tester/step_1_insert.sh  $$sut.ip workloadd $$tester.ycsb.load.threads $$tester.ycsb.load.operationcount $$tester.ycsb.recordcount

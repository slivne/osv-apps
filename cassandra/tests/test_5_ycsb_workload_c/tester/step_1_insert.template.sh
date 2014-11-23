#!/bin/bash
set -e
../../test_ycsb_helpers/tester/step_1_insert.sh  $$sut.ip workloadc $$tester.ycsb.load.threads $$tester.ycsb.load.maxoperationcount $$tester.ycsb.recordcount

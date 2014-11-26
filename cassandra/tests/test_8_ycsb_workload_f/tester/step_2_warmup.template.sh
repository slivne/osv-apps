#!/bin/bash
set -e

../../test_ycsb_helpers/tester/step_2_warmup.sh $$sut.ip workloadf "$$tester.ycsb.warmup.threads" $$tester.ycsb.warmup.iterations $$tester.ycsb.warmup.maxoperationcount $$tester.ycsb.recordcount $$tester.ycsb.fieldcount $$tester.ycsb.warmup.maxexecutiontimeinseconds $$tester.ycsb.requestdistribution 100

#!/bin/bash
set -e

../../test_ycsb_helpers/tester/step_2_run.sh $$sut.ip workloada "$$tester.ycsb.run.threads" $$tester.ycsb.run.iterations $$tester.ycsb.run.maxoperationcount $$tester.ycsb.recordcount $$tester.ycsb.fieldcount $$tester.ycsb.run.maxexecutiontimeinseconds $$tester.ycsb.requestdistribution 100

#!/bin/bash
set -e

../../test_ycsb_helpers/tester/step_2_run.sh $$sut.ip workloade $$tester.ycsb.run.threads $$tester.ycsb.run.iterations $$tester.ycsb.run.operationcount $$tester.ycsb.recordcount

#!/bin/bash
set -e

../../test_ycsb_helpers/tester/ycsbparse.py out/step_2_run.sh.stdout_stderr > out/result.txt

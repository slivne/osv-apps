#!/bin/bash
set -e

../../test_ycsb_helpers/tester/ycsbparse.py step_2_run.sh.stdout_stderr > result.txt

#!/bin/bash
set -e
../../scripts/memaslap2json.py --delimiter '$$tester.memaslap.test_delimiter' out/step_1_run.sh.stdout_stderr > out/step_1_run.sh.stdout_stderr.json
#memaslap -s $$sut.ip:11211 --threads=$$tester.memaslap.threads --concurrency=$$tester.memaslap.concurrency --time=$$tester.memaslap.duration

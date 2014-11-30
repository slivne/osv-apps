#!/bin/bash
set -e
for f in out/*.out; do
  ../../scripts/memaslap2json.py --delimiter '$$tester.memaslap.test_delimiter' $f > $f.json
done
#memaslap -s $$sut.ip:11211 --threads=$$tester.memaslap.threads --concurrency=$$tester.memaslap.concurrency --time=$$tester.memaslap.duration

#!/bin/bash
set -e
for i in `seq 1 $$tester.memaslap.retry`; do
	memaslap -s $$sut.ip:11211 --threads=$$tester.memaslap.threads --concurrency=$$tester.memaslap.concurrency --time=$$tester.memaslap.duration
	echo "$$tester.memaslap.test_delimiter"
done
#memaslap -s $$sut.ip:11211 --threads=$$tester.memaslap.threads --concurrency=$$tester.memaslap.concurrency --time=$$tester.memaslap.duration

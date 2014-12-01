#!/bin/bash
set -e
PORT= $$tester.memaslap.base_port
for i in `seq 1 $$tester.memaslap.multi`; do
  
	memaslap -s $$sut.ip:$PORT --threads=$$tester.memaslap.threads --concurrency=$$tester.memaslap.concurrency --time=$$tester.memaslap.duration > out/memaslap.$PORT.out& 
	PORT=$(( $PORT + 1 ))
	echo "$$tester.memaslap.test_delimiter"
done
#memaslap -s $$sut.ip:11211 --threads=$$tester.memaslap.threads --concurrency=$$tester.memaslap.concurrency --time=$$tester.memaslap.duration

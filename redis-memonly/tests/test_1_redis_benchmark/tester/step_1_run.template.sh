#!/bin/bash
set -e
$REDIS_BENCHMARK -h $$sut.ip -n $$tester.redis.requests -c $$tester.redis.clients

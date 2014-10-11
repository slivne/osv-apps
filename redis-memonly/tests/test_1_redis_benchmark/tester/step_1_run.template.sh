#!/bin/bash
set -e
$REDIS_BENCHMARK -h $$sut_ip -n $$tester_redis_requests -c $$tester_redis_clients

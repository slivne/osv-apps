#!/bin/bash
set -e
../../upstream/redis/src/redis-benchmark -h $sut_ip -n $tester_redis_requests -c $tester_redis_clients

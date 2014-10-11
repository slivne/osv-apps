#!/bin/bash
set -e
../../upstream/redis/src/redis-benchmark -h $sut_ip -n $sut_redis_requests -c $sut_redis_clients

#!/bin/bash
set -e

for clients in $$tester.ycsb.run.clients ; do
    for pipelines in $$tester.ycsb.run.pipelines ; do
        echo "start test
        echo "clients : $clients"
        echo "pipeline : $pipelines"
        $REDIS_BENCHMARK -h $$sut.ip -n $$tester.redis.requests -c $clients -P $pipelines
        echo "end test"
    done
done

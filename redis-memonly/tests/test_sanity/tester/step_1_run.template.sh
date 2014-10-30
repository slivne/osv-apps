#!/bin/bash
set -e

$REDIS_BENCHMARK -h $$sut.ip -n 100 -c 10 -P 16

$GENERIC_ROOT/rest/base.sh $$sut.ip


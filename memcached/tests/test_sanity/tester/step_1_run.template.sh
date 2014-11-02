#!/bin/bash
set -e

memaslap -s $$sut.ip:11211 --udp --threads=2 --concurrency=100 --time=60s

$GENERIC_ROOT/rest/base.sh $$sut.ip

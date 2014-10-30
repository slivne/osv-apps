#!/bin/bash
set -e

memaslap -s $$sut.ip:11211 --threads=10 --concurrency=10 --time=30s

$GENERIC_ROOT/rest/base.sh $$sut.ip

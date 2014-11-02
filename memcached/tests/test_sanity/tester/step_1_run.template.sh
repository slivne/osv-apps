#!/bin/bash
set -e

memslap -s $$sut.ip:11211 --udp --concurrency=10 --execute-number=5

$GENERIC_ROOT/rest/base.sh $$sut.ip
